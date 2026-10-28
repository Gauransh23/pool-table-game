#include "longrail/physics_core.hpp"

#include <algorithm>
#include <cmath>
#include <limits>
#include <utility>

namespace longrail::physics {
namespace {

constexpr double kPi = 3.141592653589793238462643383279502884;
constexpr double kContactEpsilon = 1.0e-8;
constexpr double kPositionSlop = 0.00008;
constexpr double kPositionCorrection = 0.82;

struct PairImpact {
  Vec3 normal{};
  double time_seconds = 0.0;
  bool found = false;
};

struct RailImpact {
  Vec2 normal{};
  double time_seconds = 0.0;
  bool found = false;
};

double sign(double value) { return (value > 0.0) - (value < 0.0); }

Vec2 rotate_perpendicular(const Vec2 &value) { return {-value.z, value.x}; }

Vec2 contact_slip(const Ball &ball) {
  return {ball.velocity.x + kBallRadius * ball.angular_velocity.z,
          ball.velocity.z - kBallRadius * ball.angular_velocity.x};
}

Vec3 center(const Ball &ball) {
  return {ball.position.x, ball.height, ball.position.z};
}

Vec3 linear_velocity(const Ball &ball) {
  return {ball.velocity.x, ball.vertical_velocity, ball.velocity.z};
}

PairImpact predict_pair_impact(const Ball &first, const Ball &second,
                               double duration) {
  const Vec3 relative_position = center(second) - center(first);
  const Vec3 relative_velocity = linear_velocity(second) - linear_velocity(first);
  const double diameter = 2.0 * kBallRadius;
  const double c = relative_position.length_squared() - diameter * diameter;
  if (c <= kContactEpsilon) {
    return {};
  }
  const double a = relative_velocity.length_squared();
  const double b = 2.0 * relative_position.dot(relative_velocity);
  if (a <= kContactEpsilon || b >= 0.0) {
    return {};
  }
  const double discriminant = b * b - 4.0 * a * c;
  if (discriminant < 0.0) {
    return {};
  }
  const double impact_time = (-b - std::sqrt(discriminant)) / (2.0 * a);
  if (impact_time < 0.0 || impact_time > duration) {
    return {};
  }
  const Vec3 impact_separation = relative_position + relative_velocity * impact_time;
  const Vec3 impact_normal = impact_separation.normalized();
  if (impact_normal.length_squared() < 0.5) {
    return {};
  }
  return {impact_normal, impact_time, true};
}

RailImpact predict_rail_impact(const Ball &ball, const RailSegment &segment,
                               double radius, double duration) {
  RailImpact best;
  const Vec2 segment_axis = segment.b - segment.a;
  const double segment_length_squared = segment_axis.length_squared();
  const double signed_distance =
      (ball.position - segment.a).dot(segment.inward);
  const double normal_speed = ball.velocity.dot(segment.inward);
  if (segment_length_squared > kContactEpsilon && normal_speed < -kContactEpsilon) {
    const double time = (radius - signed_distance) / normal_speed;
    if (time >= 0.0 && time <= duration) {
      const Vec2 contact = ball.position + ball.velocity * time;
      const double along = (contact - segment.a).dot(segment_axis) /
                           segment_length_squared;
      if (along >= 0.0 && along <= 1.0) {
        best = {segment.inward, time, true};
      }
    }
  }

  const double velocity_squared = ball.velocity.length_squared();
  if (velocity_squared <= kContactEpsilon) {
    return best;
  }
  for (const Vec2 &endpoint : {segment.a, segment.b}) {
    const Vec2 relative = ball.position - endpoint;
    const double c = relative.length_squared() - radius * radius;
    const double b = 2.0 * relative.dot(ball.velocity);
    if (c <= 0.0 || b >= 0.0) {
      continue;
    }
    const double discriminant = b * b - 4.0 * velocity_squared * c;
    if (discriminant < 0.0) {
      continue;
    }
    const double time = (-b - std::sqrt(discriminant)) /
                        (2.0 * velocity_squared);
    if (time < 0.0 || time > duration ||
        (best.found && time >= best.time_seconds)) {
      continue;
    }
    const Vec2 normal = (ball.position + ball.velocity * time - endpoint).normalized();
    if (normal.dot(segment.inward) >= 0.0) {
      best = {normal, time, true};
    }
  }
  return best;
}

Vec2 closest_point_on_segment(const Vec2 &point, const Vec2 &a, const Vec2 &b) {
  const Vec2 segment = b - a;
  const double length_squared = segment.length_squared();
  if (length_squared <= kContactEpsilon) {
    return a;
  }
  const double t = std::clamp((point - a).dot(segment) / length_squared, 0.0, 1.0);
  return a + segment * t;
}

void apply_impulse(Ball &ball, const Vec3 &impulse, const Vec3 &arm,
                   double mass, double inverse_inertia) {
  const Vec3 linear{ball.velocity.x + impulse.x / mass,
                    ball.vertical_velocity + impulse.y / mass,
                    ball.velocity.z + impulse.z / mass};
  ball.velocity = {linear.x, linear.z};
  ball.vertical_velocity = linear.y;
  ball.angular_velocity += arm.cross(impulse) * inverse_inertia;
}

void apply_cloth_impulse(Ball &ball, const Vec2 &planar_impulse, double mass,
                         double inertia) {
  ball.velocity += planar_impulse / mass;
  const Vec3 impulse{planar_impulse.x, 0.0, planar_impulse.z};
  const Vec3 arm{0.0, -kBallRadius, 0.0};
  ball.angular_velocity += arm.cross(impulse) / inertia;
}

Quaternion multiply(const Quaternion &a, const Quaternion &b) {
  return {
      a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
      a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
      a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
      a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
  };
}

Quaternion normalized(const Quaternion &value) {
  const double length = std::sqrt(value.x * value.x + value.y * value.y +
                                  value.z * value.z + value.w * value.w);
  if (length <= kContactEpsilon) {
    return {};
  }
  return {value.x / length, value.y / length, value.z / length, value.w / length};
}

void emit(std::vector<Event> *events, Event event) {
  if (events != nullptr) {
    events->push_back(std::move(event));
  }
}

} // namespace

double Vec2::length_squared() const { return x * x + z * z; }
double Vec2::length() const { return std::sqrt(length_squared()); }
double Vec2::dot(const Vec2 &other) const { return x * other.x + z * other.z; }

Vec2 Vec2::normalized() const {
  const double magnitude = length();
  return magnitude <= kContactEpsilon ? Vec2{} : *this / magnitude;
}

Vec2 Vec2::limited(double maximum) const {
  const double magnitude_squared = length_squared();
  if (magnitude_squared <= maximum * maximum) {
    return *this;
  }
  return normalized() * maximum;
}

Vec2 &Vec2::operator+=(const Vec2 &other) {
  x += other.x;
  z += other.z;
  return *this;
}

Vec2 &Vec2::operator-=(const Vec2 &other) {
  x -= other.x;
  z -= other.z;
  return *this;
}

Vec2 &Vec2::operator*=(double scalar) {
  x *= scalar;
  z *= scalar;
  return *this;
}

Vec2 operator+(Vec2 left, const Vec2 &right) { return left += right; }
Vec2 operator-(Vec2 left, const Vec2 &right) { return left -= right; }
Vec2 operator*(Vec2 value, double scalar) { return value *= scalar; }
Vec2 operator*(double scalar, Vec2 value) { return value *= scalar; }
Vec2 operator/(Vec2 value, double scalar) { return value *= (1.0 / scalar); }

double Vec3::length_squared() const { return x * x + y * y + z * z; }
double Vec3::length() const { return std::sqrt(length_squared()); }
double Vec3::dot(const Vec3 &other) const {
  return x * other.x + y * other.y + z * other.z;
}

Vec3 Vec3::normalized() const {
  const double magnitude = length();
  return magnitude <= kContactEpsilon ? Vec3{} : *this / magnitude;
}

Vec3 Vec3::cross(const Vec3 &other) const {
  return {y * other.z - z * other.y, z * other.x - x * other.z,
          x * other.y - y * other.x};
}

Vec3 &Vec3::operator+=(const Vec3 &other) {
  x += other.x;
  y += other.y;
  z += other.z;
  return *this;
}

Vec3 &Vec3::operator-=(const Vec3 &other) {
  x -= other.x;
  y -= other.y;
  z -= other.z;
  return *this;
}

Vec3 &Vec3::operator*=(double scalar) {
  x *= scalar;
  y *= scalar;
  z *= scalar;
  return *this;
}

Vec3 operator+(Vec3 left, const Vec3 &right) { return left += right; }
Vec3 operator-(Vec3 left, const Vec3 &right) { return left -= right; }
Vec3 operator*(Vec3 value, double scalar) { return value *= scalar; }
Vec3 operator*(double scalar, Vec3 value) { return value *= scalar; }
Vec3 operator/(Vec3 value, double scalar) { return value *= (1.0 / scalar); }

double TipOffset::length_squared() const {
  return side * side + vertical * vertical;
}

double TipOffset::length() const { return std::sqrt(length_squared()); }

bool Ball::is_on_table() const {
  return phase == Phase::in_play || phase == Phase::airborne;
}

void Ball::advance_orientation(double delta_seconds) {
  const double angular_speed = angular_velocity.length();
  if (angular_speed <= 1.0e-10) {
    return;
  }
  const double half_angle = angular_speed * delta_seconds * 0.5;
  const double sine = std::sin(half_angle);
  const Vec3 axis = angular_velocity / angular_speed;
  const Quaternion delta{axis.x * sine, axis.y * sine, axis.z * sine,
                         std::cos(half_angle)};
  orientation = normalized(multiply(delta, orientation));
}

std::array<double, 17> Ball::canonical_state() const {
  return {static_cast<double>(id),
          static_cast<double>(number),
          position.x,
          position.z,
          height,
          velocity.x,
          velocity.z,
          vertical_velocity,
          angular_velocity.x,
          angular_velocity.y,
          angular_velocity.z,
          orientation.x,
          orientation.y,
          orientation.z,
          orientation.w,
          static_cast<double>(phase),
          static_cast<double>(pocket_id)};
}

std::vector<RailSegment> TableSpec::rail_segments() const {
  std::vector<RailSegment> segments;
  segments.reserve(22);
  const double corner_gap = corner_mouth / std::sqrt(2.0);
  const double side_gap = side_mouth * 0.5;
  const auto add_face = [&segments](Vec2 a, Vec2 b, Vec2 inward) {
    if ((b - a).length_squared() > 1.0e-8) {
      segments.push_back({a, b, inward, false});
    }
  };
  const auto add_jaw = [&segments](Vec2 a, Vec2 b) {
    const Vec2 tangent = b - a;
    Vec2 inward = rotate_perpendicular(tangent).normalized();
    const Vec2 middle = (a + b) * 0.5;
    if (inward.dot(middle * -1.0) < 0.0) {
      inward *= -1.0;
    }
    segments.push_back({a, b, inward, true});
  };

  for (double side_sign : {-1.0, 1.0}) {
    const double z = side_sign * half_width;
    const Vec2 inward{0.0, -side_sign};
    add_face({-half_length + corner_gap, z}, {-side_gap, z}, inward);
    add_face({side_gap, z}, {half_length - corner_gap, z}, inward);
  }
  for (double end_sign : {-1.0, 1.0}) {
    const double x = end_sign * half_length;
    const Vec2 inward{-end_sign, 0.0};
    add_face({x, -half_width + corner_gap}, {x, half_width - corner_gap}, inward);
  }
  for (double x_sign : {-1.0, 1.0}) {
    for (double z_sign : {-1.0, 1.0}) {
      const Vec2 throat{x_sign * (half_length + pocket_depth),
                        z_sign * (half_width + pocket_depth)};
      add_jaw({x_sign * (half_length - corner_gap), z_sign * half_width}, throat);
      add_jaw({x_sign * half_length, z_sign * (half_width - corner_gap)}, throat);
    }
  }
  for (double z_sign : {-1.0, 1.0}) {
    const Vec2 throat{0.0, z_sign * (half_width + pocket_depth)};
    add_jaw({-side_gap, z_sign * half_width}, throat);
    add_jaw({side_gap, z_sign * half_width}, throat);
  }
  return segments;
}

std::array<double, 4> TableSpec::corner_mouth_widths() const {
  std::array<std::array<Vec2, 2>, 4> tips{};
  std::array<int, 4> counts{};
  for (const RailSegment &segment : rail_segments()) {
    if (!segment.jaw || std::abs(segment.a.x) <= half_length * 0.7 ||
        std::abs(segment.a.z) <= half_width * 0.7) {
      continue;
    }
    const int x_index = segment.a.x > 0.0 ? 1 : 0;
    const int z_index = segment.a.z > 0.0 ? 1 : 0;
    const int pocket = x_index * 2 + z_index;
    if (counts[static_cast<std::size_t>(pocket)] < 2) {
      tips[static_cast<std::size_t>(pocket)][static_cast<std::size_t>(counts[static_cast<std::size_t>(pocket)])] = segment.a;
      ++counts[static_cast<std::size_t>(pocket)];
    }
  }
  std::array<double, 4> widths{};
  for (std::size_t index = 0; index < widths.size(); ++index) {
    widths[index] = counts[index] == 2 ?
        (tips[index][0] - tips[index][1]).length() : 0.0;
  }
  return widths;
}

int TableSpec::pocket_at(const Vec2 &position) const {
  const double x_limit = half_length - kBallRadius;
  const double z_limit = half_width - kBallRadius;
  if (std::abs(position.x) > x_limit && std::abs(position.z) > z_limit) {
    for (double x_sign : {-1.0, 1.0}) {
      for (double z_sign : {-1.0, 1.0}) {
        if (x_sign * position.x > x_limit && z_sign * position.z > z_limit) {
          if (x_sign < 0.0) {
            return z_sign > 0.0 ? 0 : 1;
          }
          return z_sign > 0.0 ? 2 : 3;
        }
      }
    }
  }
  if (std::abs(position.z) > z_limit &&
      std::abs(position.x) < side_mouth * 0.5 - kBallRadius * 0.18) {
    return position.z > 0.0 ? 4 : 5;
  }
  return -1;
}

bool TableSpec::outside_table(const Vec2 &position) const {
  return std::abs(position.x) > half_length || std::abs(position.z) > half_width;
}

CueStrikeResult apply_cue_strike(Ball &ball, const CueStrikeParameters &shot,
                                 const PhysicsConfig &physics,
                                 const CueConfig &cue) {
  CueStrikeResult result;
  const double direction_length_squared = shot.direction.length_squared();
  if (direction_length_squared < 1.0e-10 || shot.cue_speed <= 0.0 ||
      !ball.is_on_table()) {
    return result;
  }
  const double offset_length = shot.tip_offset.length();
  if (offset_length > cue.stable_tip_offset + 1.0e-9) {
    result.miscue = true;
    return result;
  }
  const Vec2 planar_direction = shot.direction.normalized();
  const double elevation = std::clamp(shot.cue_elevation, 0.0, 65.0 * kPi / 180.0);
  const Vec3 axis{planar_direction.x * std::cos(elevation),
                  -std::sin(elevation),
                  planar_direction.z * std::cos(elevation)};
  const Vec3 lateral{-planar_direction.z, 0.0, planar_direction.x};
  Vec3 contact_up = Vec3{0.0, 1.0, 0.0} - axis * axis.y;
  if (contact_up.length_squared() < 1.0e-8) {
    contact_up = Vec3{1.0, 0.0, 0.0} - axis * axis.x;
  }
  contact_up = contact_up.normalized();
  const double normal_component = std::sqrt(std::max(0.0, 1.0 - offset_length * offset_length));
  const Vec3 contact_arm =
      (axis * -normal_component + lateral * shot.tip_offset.side +
      contact_up * shot.tip_offset.vertical) * kBallRadius;
  const double cue_mass = std::max(0.01, cue.mass);
  const double ball_mass = std::max(0.01, physics.ball_mass);
  const double mass_ratio = ball_mass / cue_mass;
  const double denominator = 1.0 + mass_ratio + 2.5 * offset_length * offset_length;
  const double discriminant =
      1.0 - denominator * (1.0 - cue.collision_efficiency) / mass_ratio;
  if (discriminant < 0.0) {
    result.miscue = true;
    return result;
  }
  result.ball_speed = shot.cue_speed * (1.0 + std::sqrt(discriminant)) / denominator;
  if (std::abs(shot.tip_offset.side) > 1.0e-9) {
    const double beta = std::abs(shot.tip_offset.side);
    const double end_mass = std::max(0.001, cue.effective_end_mass);
    const double endmass_ratio = ball_mass / end_mass;
    const double numerator = 2.5 * beta * std::sqrt(std::max(0.0, 1.0 - beta * beta));
    const double squirt_denominator = 1.0 + endmass_ratio + 2.5 * (1.0 - beta * beta);
    result.squirt_angle = sign(shot.tip_offset.side) * std::atan(numerator / squirt_denominator);
  }
  const double c = std::cos(-result.squirt_angle);
  const double s = std::sin(-result.squirt_angle);
  const Vec2 squirted{planar_direction.x * c - planar_direction.z * s,
                      planar_direction.x * s + planar_direction.z * c};
  const Vec3 impulse_axis{squirted.x * std::cos(elevation), -std::sin(elevation),
                          squirted.z * std::cos(elevation)};
  const Vec3 impulse = impulse_axis.normalized() * (ball_mass * result.ball_speed);
  const Vec3 new_linear{ball.velocity.x + impulse.x / ball_mass,
                        ball.vertical_velocity + impulse.y / ball_mass,
                        ball.velocity.z + impulse.z / ball_mass};
  ball.velocity = {new_linear.x, new_linear.z};
  ball.vertical_velocity = new_linear.y;
  const double inertia = 0.4 * ball_mass * kBallRadius * kBallRadius;
  ball.angular_velocity += contact_arm.cross(impulse) / inertia;
  ball.phase = ball.vertical_velocity > 0.035 ? Phase::airborne : Phase::in_play;
  result.applied = true;
  return result;
}

std::uint64_t Simulator::advance(std::vector<Ball> &balls,
                                 double elapsed_seconds,
                                 const PhysicsConfig &config,
                                 const TableSpec &table,
                                 std::vector<Event> *events) {
  if (elapsed_seconds <= 0.0) {
    return 0;
  }
  accumulator_ += elapsed_seconds;
  const std::vector<RailSegment> rails = table.rail_segments();
  std::uint64_t ticks = 0;
  while (accumulator_ + 1.0e-12 >= config.fixed_step) {
    step_with_rails(balls, config.fixed_step, config, table, rails, events);
    accumulator_ -= config.fixed_step;
    simulated_seconds_ += config.fixed_step;
    ++fixed_ticks_;
    ++ticks;
  }
  return ticks;
}

void Simulator::step_fixed(std::vector<Ball> &balls, double delta_seconds,
                           const PhysicsConfig &config, const TableSpec &table,
                           std::vector<Event> *events) {
  if (delta_seconds <= 0.0) {
    return;
  }
  const std::vector<RailSegment> rails = table.rail_segments();
  step_with_rails(balls, delta_seconds, config, table, rails, events);
  simulated_seconds_ += delta_seconds;
  ++fixed_ticks_;
}

bool Simulator::settled(const std::vector<Ball> &balls,
                         const PhysicsConfig &config) const {
  for (const Ball &ball : balls) {
    if (ball.phase == Phase::airborne || ball.phase == Phase::falling) {
      return false;
    }
    if (ball.phase == Phase::off_table && ball.height > kOffTableTerminalHeight) {
      return false;
    }
    if (ball.phase == Phase::in_play &&
        (ball.velocity.length() > config.sleep_speed_threshold ||
         ball.angular_velocity.length() > config.sleep_spin_threshold)) {
      return false;
    }
  }
  return true;
}

std::uint64_t Simulator::fixed_ticks() const { return fixed_ticks_; }

double Simulator::simulated_seconds() const { return simulated_seconds_; }

void Simulator::step_with_rails(std::vector<Ball> &balls, double delta_seconds,
                                const PhysicsConfig &config,
                                const TableSpec &table,
                                const std::vector<RailSegment> &rails,
                                std::vector<Event> *events) {
  double fastest = 0.0;
  for (const Ball &ball : balls) {
    if (ball.is_on_table()) {
      fastest = std::max({fastest, ball.velocity.length(),
                          std::abs(ball.vertical_velocity)});
    }
  }
  const double travel_limit =
      std::max(0.006, kBallRadius * config.max_substep_travel_fraction);
  const int substeps = std::max(1, static_cast<int>(
      std::ceil(fastest * delta_seconds / travel_limit)));
  const double sub_delta = delta_seconds / static_cast<double>(substeps);
  for (int substep = 0; substep < substeps; ++substep) {
    const double event_time = simulated_seconds_ + sub_delta * substep;
    const double event_time_end = event_time + sub_delta;
    const std::vector<Ball> previous_balls = balls;
    integrate_balls(balls, sub_delta, config, table, event_time, events);
    for (int iteration = 0; iteration < config.max_collision_iterations; ++iteration) {
      bool any_contact = false;
      for (std::size_t first_index = 0; first_index < balls.size(); ++first_index) {
        Ball &first = balls[first_index];
        if (!first.is_on_table()) {
          continue;
        }
        for (std::size_t second_index = first_index + 1;
             second_index < balls.size(); ++second_index) {
          Ball &second = balls[second_index];
          if (!second.is_on_table()) {
            continue;
          }
          any_contact = resolve_ball_pair(
                            first, second,
                            previous_balls[first_index],
                            previous_balls[second_index], sub_delta, config,
                            event_time, events) ||
                        any_contact;
        }
      }
      for (std::size_t ball_index = 0; ball_index < balls.size(); ++ball_index) {
        Ball &ball = balls[ball_index];
        if (ball.is_on_table()) {
          any_contact = resolve_rails(
                            ball, config, previous_balls[ball_index], sub_delta,
                            table, rails, event_time, events) ||
                        any_contact;
        }
      }
      if (!any_contact) {
        break;
      }
    }
    classify_exits(balls, table, event_time_end, events);
  }
}

void Simulator::integrate_balls(std::vector<Ball> &balls, double delta_seconds,
                                const PhysicsConfig &config,
                                const TableSpec &table,
                                double event_time,
                                std::vector<Event> *events) {
  (void)table;
  for (Ball &ball : balls) {
    if (ball.phase == Phase::pocketed) {
      continue;
    }
    if (ball.phase == Phase::off_table) {
      if (ball.height <= kOffTableTerminalHeight) {
        ball.height = kOffTableTerminalHeight;
        ball.velocity = {};
        ball.vertical_velocity = 0.0;
        ball.angular_velocity = {};
        continue;
      }
      ball.vertical_velocity -= config.gravity * delta_seconds;
      ball.height += ball.vertical_velocity * delta_seconds;
      ball.position += ball.velocity * delta_seconds;
      ball.advance_orientation(delta_seconds);
      if (ball.height < kOffTableTerminalHeight) {
        ball.height = kOffTableTerminalHeight;
        ball.velocity = {};
        ball.vertical_velocity = 0.0;
        ball.angular_velocity = {};
      }
      continue;
    }
    if (ball.phase == Phase::falling) {
      ball.vertical_velocity -= config.gravity * delta_seconds;
      ball.height += ball.vertical_velocity * delta_seconds;
      ball.velocity *= std::exp(-1.1 * delta_seconds);
      ball.position += ball.velocity * delta_seconds;
      if (ball.height < kOffTableTerminalHeight) {
        ball.phase = Phase::pocketed;
        emit(events, {event_time + delta_seconds, EventKind::pocketed,
                      ball.id, -1, ball.pocket_id,
                      {ball.position.x, ball.height, ball.position.z}, {}, 0.0});
      }
      continue;
    }
    if (ball.height > kBallRadius + 1.0e-5 ||
        ball.vertical_velocity > 1.0e-4) {
      ball.phase = Phase::airborne;
      ball.vertical_velocity -= config.gravity * delta_seconds;
      ball.height += ball.vertical_velocity * delta_seconds;
      ball.position += ball.velocity * delta_seconds;
      if (ball.height < kBallRadius) {
        ball.height = kBallRadius;
        ball.vertical_velocity = -ball.vertical_velocity * 0.18;
        if (std::abs(ball.vertical_velocity) < 0.08) {
          ball.vertical_velocity = 0.0;
          ball.phase = Phase::in_play;
        }
        emit(events, {event_time + delta_seconds, EventKind::landing,
                      ball.id, -1, -1,
                      {ball.position.x, ball.height, ball.position.z},
                      {0.0, 1.0, 0.0}, std::abs(ball.vertical_velocity)});
      }
    } else {
      ball.phase = Phase::in_play;
      ball.height = kBallRadius;
      ball.vertical_velocity = 0.0;
      const double slip_before = contact_slip(ball).length();
      apply_cloth_friction(ball, delta_seconds, config);
      const double slip_after = contact_slip(ball).length();
      ball.position += ball.velocity * delta_seconds;
      if (slip_before > 0.0005 && slip_after <= 0.0005) {
        emit(events, {event_time + delta_seconds, EventKind::slide_to_roll,
                      ball.id, -1, -1,
                      {ball.position.x, ball.height, ball.position.z}, {}, slip_before});
      }
    }
    ball.advance_orientation(delta_seconds);
    if (ball.velocity.length() < config.sleep_speed_threshold &&
        ball.angular_velocity.length() < config.sleep_spin_threshold &&
        ball.phase == Phase::in_play) {
      const bool was_moving = ball.velocity.length_squared() > 0.0 ||
                              ball.angular_velocity.length_squared() > 0.0;
      ball.velocity = {};
      ball.angular_velocity = {};
      ball.vertical_velocity = 0.0;
      ball.height = kBallRadius;
      if (was_moving) {
        emit(events, {event_time + delta_seconds, EventKind::stationary,
                      ball.id, -1, -1,
                      {ball.position.x, ball.height, ball.position.z}, {}, 0.0});
      }
    }
  }
}

void Simulator::apply_cloth_friction(Ball &ball, double delta_seconds,
                                     const PhysicsConfig &config) {
  const Vec2 slip{ball.velocity.x + kBallRadius * ball.angular_velocity.z,
                  ball.velocity.z - kBallRadius * ball.angular_velocity.x};
  const double inertia = 0.4 * config.ball_mass * kBallRadius * kBallRadius;
  const double rotational_inverse_mass = kBallRadius * kBallRadius / inertia;
  if (slip.length() > 0.0005) {
    const double impulse_limit =
        config.sliding_friction * config.ball_mass * config.gravity * delta_seconds;
    const double impulse_needed =
        slip.length() / (1.0 / config.ball_mass + rotational_inverse_mass);
    const double impulse_magnitude = std::min(impulse_limit, impulse_needed);
    apply_cloth_impulse(ball, slip.normalized() * -impulse_magnitude,
                        config.ball_mass, inertia);
  } else {
    const double speed = ball.velocity.length();
    if (speed > 1.0e-7) {
      const double new_speed = std::max(
          0.0, speed - config.rolling_resistance * config.gravity * delta_seconds);
      ball.velocity = ball.velocity.normalized() * new_speed;
      ball.angular_velocity.x = ball.velocity.z / kBallRadius;
      ball.angular_velocity.z = -ball.velocity.x / kBallRadius;
    } else {
      ball.velocity = {};
      ball.angular_velocity.x = 0.0;
      ball.angular_velocity.z = 0.0;
    }
  }
  const double spin_speed = std::abs(ball.angular_velocity.y);
  const double spin_deceleration =
      5.0 * config.spinning_friction * config.gravity / (2.0 * kBallRadius);
  ball.angular_velocity.y = sign(ball.angular_velocity.y) *
      std::max(0.0, spin_speed - spin_deceleration * delta_seconds);
}

bool Simulator::resolve_ball_pair(Ball &first, Ball &second,
                                  const Ball &previous_first,
                                  const Ball &previous_second,
                                  double substep_seconds,
                                  const PhysicsConfig &config,
                                  double event_time,
                                  std::vector<Event> *events) {
  const Vec3 first_position{first.position.x, first.height, first.position.z};
  const Vec3 second_position{second.position.x, second.height, second.position.z};
  const Vec3 separation = second_position - first_position;
  const double distance_squared = separation.length_squared();
  const double diameter = 2.0 * kBallRadius;
  if (distance_squared >= diameter * diameter) {
    return false;
  }
  const double distance = std::sqrt(std::max(distance_squared, kContactEpsilon));
  const Vec3 current_normal = distance_squared > kContactEpsilon ?
      separation / distance : Vec3{1.0, 0.0, 0.0};
  const PairImpact impact =
      predict_pair_impact(previous_first, previous_second, substep_seconds);
  const Vec3 normal = impact.found ? impact.normal : current_normal;
  const double penetration = diameter - distance;
  const double correction =
      std::max(0.0, penetration - kPositionSlop) * kPositionCorrection * 0.5;
  first.position -= Vec2{current_normal.x, current_normal.z} * correction;
  second.position += Vec2{current_normal.x, current_normal.z} * correction;
  first.height -= current_normal.y * correction;
  second.height += current_normal.y * correction;

  const Vec3 first_arm = normal * kBallRadius;
  const Vec3 second_arm = normal * -kBallRadius;
  const Vec3 first_contact =
      Vec3{first.velocity.x, first.vertical_velocity, first.velocity.z} +
      first.angular_velocity.cross(first_arm);
  const Vec3 second_contact =
      Vec3{second.velocity.x, second.vertical_velocity, second.velocity.z} +
      second.angular_velocity.cross(second_arm);
  const Vec3 relative = second_contact - first_contact;
  const double normal_speed = relative.dot(normal);
  if (normal_speed >= 0.0) {
    return true;
  }
  const double inverse_mass = 1.0 / config.ball_mass;
  const double inverse_inertia =
      1.0 / (0.4 * config.ball_mass * kBallRadius * kBallRadius);
  const double normal_impulse =
      -(1.0 + config.ball_restitution) * normal_speed / (2.0 * inverse_mass);
  const Vec3 normal_vector = normal * normal_impulse;
  apply_impulse(first, normal_vector * -1.0, first_arm, config.ball_mass,
                inverse_inertia);
  apply_impulse(second, normal_vector, second_arm, config.ball_mass,
                inverse_inertia);

  const Vec3 tangent_velocity = relative - normal * normal_speed;
  const double tangent_speed = tangent_velocity.length();
  if (tangent_speed > kContactEpsilon && config.ball_friction > 0.0) {
    const Vec3 tangent = tangent_velocity / tangent_speed;
    const Vec3 first_axis = first_arm.cross(tangent);
    const Vec3 second_axis = second_arm.cross(tangent);
    const double tangent_denominator =
        2.0 * inverse_mass +
        (first_axis.length_squared() + second_axis.length_squared()) * inverse_inertia;
    const double desired = tangent_speed / tangent_denominator;
    const double tangent_impulse =
        std::min(desired, config.ball_friction * normal_impulse);
    const Vec3 tangent_vector = tangent * -tangent_impulse;
    apply_impulse(first, tangent_vector * -1.0, first_arm, config.ball_mass,
                  inverse_inertia);
    apply_impulse(second, tangent_vector, second_arm, config.ball_mass,
                  inverse_inertia);
  }

  const Vec3 contact_position = impact.found ?
      (center(previous_first) + linear_velocity(previous_first) * impact.time_seconds +
       center(previous_second) + linear_velocity(previous_second) * impact.time_seconds) *
          0.5 :
      (first_position + second_position) * 0.5;
  emit(events, {event_time + (impact.found ? impact.time_seconds : 0.0),
                EventKind::ball_contact, first.id, second.id, -1,
                contact_position, normal, -normal_speed});
  return true;
}

bool Simulator::resolve_rails(Ball &ball, const PhysicsConfig &config,
                              const Ball &previous_ball,
                              double substep_seconds,
                              const TableSpec &table,
                              const std::vector<RailSegment> &rails,
                              double event_time, std::vector<Event> *events) {
  const double nose_offset = table.cushion_nose_height - ball.height;
  if (std::abs(nose_offset) >= kBallRadius) {
    return false;
  }
  const double horizontal_radius =
      std::sqrt(kBallRadius * kBallRadius - nose_offset * nose_offset);
  bool touched = false;
  const double inertia = 0.4 * config.ball_mass * kBallRadius * kBallRadius;
  const double inverse_inertia = 1.0 / inertia;
  for (std::size_t index = 0; index < rails.size(); ++index) {
    const RailSegment &segment = rails[index];
    const RailImpact impact =
        predict_rail_impact(previous_ball, segment, horizontal_radius,
                            substep_seconds);
    const Vec2 closest = closest_point_on_segment(ball.position, segment.a, segment.b);
    const Vec2 offset = ball.position - closest;
    const double signed_distance = offset.dot(segment.inward);
    if ((signed_distance < -0.001 && !impact.found) ||
        offset.length_squared() >= horizontal_radius * horizontal_radius) {
      continue;
    }
    Vec2 planar_normal = offset.length_squared() > kContactEpsilon ?
        offset.normalized() : segment.inward;
    if (planar_normal.dot(segment.inward) < 0.0) {
      planar_normal = segment.inward;
    }
    if (impact.found) {
      planar_normal = impact.normal;
    }
    const double distance = offset.length();
    const double correction = std::max(0.0, horizontal_radius - distance);
    ball.position += planar_normal * correction;
    const Vec3 normal{planar_normal.x * horizontal_radius / kBallRadius,
                      -nose_offset / kBallRadius,
                      planar_normal.z * horizontal_radius / kBallRadius};
    const Vec3 arm{-planar_normal.x * horizontal_radius, nose_offset,
                   -planar_normal.z * horizontal_radius};
    const Vec3 contact =
        Vec3{ball.velocity.x, ball.vertical_velocity, ball.velocity.z} +
        ball.angular_velocity.cross(arm);
    const double normal_speed = contact.dot(normal);
    if (normal_speed < 0.0) {
      const Vec3 normal_axis = arm.cross(normal);
      const double normal_denominator =
          1.0 / config.ball_mass + normal_axis.length_squared() * inverse_inertia;
      const double normal_impulse =
          -(1.0 + config.cushion_restitution) * normal_speed / normal_denominator;
      Vec3 impulse = normal * normal_impulse;
      const Vec3 tangent_velocity = contact - normal * normal_speed;
      if (tangent_velocity.length_squared() > kContactEpsilon &&
          config.cushion_friction > 0.0) {
        const Vec3 tangent = tangent_velocity.normalized();
        const Vec3 tangent_axis = arm.cross(tangent);
        const double tangent_denominator =
            1.0 / config.ball_mass + tangent_axis.length_squared() * inverse_inertia;
        const double desired = tangent_velocity.length() / tangent_denominator;
        const double tangent_impulse =
            std::min(desired, config.cushion_friction * normal_impulse);
        impulse -= tangent * tangent_impulse;
      }
      apply_impulse(ball, impulse, arm, config.ball_mass, inverse_inertia);
      const Vec3 contact_position = impact.found ?
          center(previous_ball) +
              linear_velocity(previous_ball) * impact.time_seconds :
          Vec3{ball.position.x, ball.height, ball.position.z};
      emit(events, {event_time + (impact.found ? impact.time_seconds : 0.0),
                    segment.jaw ? EventKind::jaw_contact : EventKind::cushion_contact,
                    ball.id, -1, static_cast<int>(index),
                    contact_position, normal,
                    -normal_speed});
    }
    touched = true;
  }
  return touched;
}

void Simulator::classify_exits(std::vector<Ball> &balls, const TableSpec &table,
                               double event_time, std::vector<Event> *events) {
  for (Ball &ball : balls) {
    if (!ball.is_on_table()) {
      continue;
    }
    const int pocket = table.pocket_at(ball.position);
    if (pocket >= 0 && ball.height <= kBallRadius + 0.002) {
      ball.phase = Phase::falling;
      ball.pocket_id = pocket;
      ball.vertical_velocity =
          std::min(ball.vertical_velocity,
                   -std::max(0.28, ball.velocity.length() * 0.08));
      emit(events, {event_time, EventKind::pocket_entry, ball.id, -1, pocket,
                    {ball.position.x, ball.height, ball.position.z}, {},
                    ball.velocity.length()});
    } else if (table.outside_table(ball.position)) {
      ball.phase = Phase::off_table;
      emit(events, {event_time, EventKind::off_table, ball.id, -1, -1,
                    {ball.position.x, ball.height, ball.position.z}, {},
                    ball.velocity.length()});
    }
  }
}

} // namespace longrail::physics
