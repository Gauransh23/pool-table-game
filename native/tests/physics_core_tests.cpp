#include "longrail/physics_core.hpp"

#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <string>
#include <vector>

using namespace longrail::physics;

namespace {

int checks = 0;

void expect(bool condition, const std::string &message) {
  ++checks;
  if (!condition) {
    throw std::runtime_error("FAIL: " + message);
  }
}

void expect_near(double actual, double expected, double tolerance,
                 const std::string &message) {
  expect(std::abs(actual - expected) <= tolerance,
         message + " (actual=" + std::to_string(actual) +
             ", expected=" + std::to_string(expected) + ")");
}

PhysicsConfig quiet_config() {
  PhysicsConfig config;
  config.sliding_friction = 0.0;
  config.rolling_resistance = 0.0;
  config.spinning_friction = 0.0;
  config.ball_restitution = 0.98;
  config.ball_friction = 0.0;
  config.cushion_friction = 0.0;
  return config;
}

void test_rolling_resistance_and_stopping_distance() {
  PhysicsConfig config = quiet_config();
  config.rolling_resistance = 0.012;
  Ball initial;
  initial.velocity = {0.5, 0.0};
  initial.angular_velocity.z = -initial.velocity.x / kBallRadius;
  std::vector<Ball> balls{initial};
  Simulator simulator;
  const TableSpec table;
  (void)simulator.advance(balls, 1.0, config, table);

  const double deceleration = config.rolling_resistance * config.gravity;
  expect_near(balls[0].velocity.x, 0.5 - deceleration, 0.001,
              "rolling speed has constant deceleration");
  expect_near(balls[0].position.x, 0.5 - 0.5 * deceleration, 0.0005,
              "rolling displacement follows analytic kinematics");

  (void)simulator.advance(balls, 5.0, config, table);
  expect_near(balls[0].velocity.length(), 0.0, 1.0e-8,
              "rolling ball reaches a stationary state");
  expect_near(balls[0].position.x, 0.5 * 0.5 / (2.0 * deceleration), 0.001,
              "rolling stopping distance matches v squared over 2a");
}

void test_stun_to_roll_reference() {
  PhysicsConfig config = quiet_config();
  config.sliding_friction = 0.2;
  const double transition_time = 80.0 * config.fixed_step;
  const double initial_speed =
      transition_time * 7.0 * config.sliding_friction * config.gravity / 2.0;
  Ball initial;
  initial.velocity = {initial_speed, 0.0};
  std::vector<Ball> balls{initial};
  Simulator simulator;
  const TableSpec table;
  (void)simulator.advance(balls, transition_time, config, table);

  const double expected_speed = (5.0 / 7.0) * initial_speed;
  const double expected_distance =
      12.0 * initial_speed * initial_speed /
      (49.0 * config.sliding_friction * config.gravity);
  expect_near(balls[0].velocity.x, expected_speed, 0.001,
              "stun transition speed matches the 5/7 reference");
  expect_near(balls[0].position.x, expected_distance, 0.0005,
              "stun transition displacement matches the analytic reference");
}

void test_sidespin_decay() {
  PhysicsConfig config;
  Ball initial;
  initial.angular_velocity.y = 30.0;
  std::vector<Ball> balls{initial};
  Simulator simulator;
  const TableSpec table;
  const double deceleration =
      5.0 * config.spinning_friction * config.gravity / (2.0 * kBallRadius);
  (void)simulator.advance(balls, 1.0, config, table);
  expect_near(balls[0].angular_velocity.y, 30.0 - deceleration, 0.01,
              "spinning state has constant angular deceleration");
  (void)simulator.advance(balls, 2.0, config, table);
  expect_near(balls[0].angular_velocity.y, 0.0, 1.0e-8,
              "spinning state reaches rest in finite time");
}

void test_head_on_collision_and_event() {
  PhysicsConfig config = quiet_config();
  config.ball_restitution = 1.0;
  Ball first;
  first.id = 0;
  first.position = {-0.033, 0.0};
  first.velocity = {1.0, 0.0};
  Ball second;
  second.id = 1;
  second.number = 1;
  second.position = {0.033, 0.0};
  std::vector<Ball> balls{first, second};
  Simulator simulator;
  const TableSpec table;
  std::vector<Event> events;
  (void)simulator.advance(balls, 0.12, config, table, &events);
  expect_near(balls[0].velocity.x, 0.0, 0.03,
              "equal-mass striker nearly stops after a head-on impact");
  expect_near(balls[1].velocity.x, 1.0, 0.03,
              "equal-mass object ball receives the incoming speed");
  expect((balls[0].position - balls[1].position).length() >=
             2.0 * kBallRadius - 0.0005,
         "balls do not remain deeply interpenetrating");
  const auto contact_event = std::find_if(
      events.begin(), events.end(), [](const Event &event) {
        return event.kind == EventKind::ball_contact && event.ball_a == 0 &&
               event.ball_b == 1;
      });
  expect(contact_event != events.end(),
         "ball contact event identifies the two contacted balls");
  if (contact_event != events.end()) {
    expect_near(contact_event->time_seconds, 0.066 - 2.0 * kBallRadius,
                1.0e-9, "time-of-impact event reports the analytic contact time");
  }
}

void test_fixed_step_chunking_and_tick_count() {
  PhysicsConfig config = quiet_config();
  config.sliding_friction = 0.17;
  Ball initial;
  initial.position = {-0.4, 0.1};
  initial.velocity = {2.2, 0.37};
  std::vector<Ball> one_chunk{initial};
  std::vector<Ball> two_chunks{initial};
  Simulator one_simulator;
  Simulator split_simulator;
  const TableSpec table;
  (void)one_simulator.advance(one_chunk, 0.5, config, table);
  (void)split_simulator.advance(two_chunks, 0.2, config, table);
  (void)split_simulator.advance(two_chunks, 0.3, config, table);
  expect((one_chunk[0].position - two_chunks[0].position).length() < 1.0e-9,
         "fixed-step position is independent of elapsed-time chunking");
  expect((one_chunk[0].velocity - two_chunks[0].velocity).length() < 1.0e-9,
         "fixed-step velocity is independent of elapsed-time chunking");
  expect(one_simulator.fixed_ticks() == 240 &&
             split_simulator.fixed_ticks() == 240,
         "tick counter counts fixed simulation steps");
  expect_near(one_simulator.simulated_seconds(), 0.5, 1.0e-10,
              "simulator reports accumulated fixed-step time");
}

void test_cushion_geometry_and_airborne_clearance() {
  const TableSpec table;
  for (double mouth : table.corner_mouth_widths()) {
    expect(mouth >= 0.1143 && mouth <= 0.1175,
           "derived corner jaw-tip mouth is inside the WPA range");
  }
  PhysicsConfig config = quiet_config();
  Ball ball;
  ball.position = {table.half_length - kBallRadius - 0.002, 0.0};
  ball.height = 2.5 * kBallRadius;
  ball.velocity = {1.0, 0.0};
  ball.phase = Phase::airborne;
  std::vector<Ball> balls{ball};
  Simulator simulator;
  (void)simulator.advance(balls, 0.00625, config, table);
  expect(balls[0].velocity.x > 0.9,
         "airborne ball clears the cushion nose without a planar-only rebound");
}

void test_cushion_time_of_impact() {
  PhysicsConfig config = quiet_config();
  config.cushion_restitution = 0.84;
  const TableSpec table;
  const double nose_offset = table.cushion_nose_height - kBallRadius;
  const double horizontal_radius =
      std::sqrt(kBallRadius * kBallRadius - nose_offset * nose_offset);
  Ball ball;
  ball.id = 7;
  ball.position = {table.half_length - horizontal_radius - 0.1, 0.0};
  ball.velocity = {1.0, 0.0};
  std::vector<Ball> balls{ball};
  std::vector<Event> events;
  Simulator simulator;
  (void)simulator.advance(balls, 0.2, config, table, &events);

  const auto cushion_event = std::find_if(
      events.begin(), events.end(), [](const Event &event) {
        return event.kind == EventKind::cushion_contact && event.ball_a == 7;
      });
  expect(cushion_event != events.end(), "cushion collision emits a rail event");
  if (cushion_event != events.end()) {
    expect_near(cushion_event->time_seconds, 0.1, 1.0e-9,
                "time-of-impact rail event reports the analytic contact time");
  }
  expect(balls[0].velocity.x < 0.0,
         "time-of-impact rail resolution reverses incoming normal motion");
}

void test_cue_strike_energy_squirt_and_miscue() {
  PhysicsConfig physics = quiet_config();
  CueConfig cue;
  const double speed = 5.0;
  const double offset = cue.stable_tip_offset;
  const double mass_ratio = physics.ball_mass / cue.mass;
  const double denominator = 1.0 + mass_ratio + 2.5 * offset * offset;
  const double radicand =
      1.0 - denominator * (1.0 - cue.collision_efficiency) / mass_ratio;
  const double expected_speed = speed * (1.0 + std::sqrt(radicand)) / denominator;
  Ball ball;
  CueStrikeParameters shot;
  shot.direction = {1.0, 0.0};
  shot.cue_speed = speed;
  shot.tip_offset = {offset, 0.0};
  const CueStrikeResult result = apply_cue_strike(ball, shot, physics, cue);
  expect(result.applied && !result.miscue,
         "maximum stable tip offset produces a modeled strike");
  expect_near(ball.velocity.length(), expected_speed, 0.002,
              "cue-ball speed matches the Alciatore TP A.30 efficiency model");
  const double ball_energy =
      0.5 * physics.ball_mass * ball.velocity.length_squared() +
      0.5 * kBallInertia * ball.angular_velocity.length_squared();
  const double cue_energy = 0.5 * cue.mass * speed * speed;
  expect(ball_energy <= cue_energy * cue.collision_efficiency * 1.00001,
         "cue impulse does not create kinetic energy");

  const double beta = offset;
  const double end_mass_ratio = physics.ball_mass / cue.effective_end_mass;
  const double squirt_denominator =
      1.0 + end_mass_ratio + 2.5 * (1.0 - beta * beta);
  const double expected_squirt =
      std::atan((2.5 * beta * std::sqrt(1.0 - beta * beta)) /
                squirt_denominator);
  expect_near(result.squirt_angle, expected_squirt, 1.0e-6,
              "squirt follows the Alciatore TP A.31 effective-endmass formula");

  Ball miscued;
  CueStrikeParameters miscue_shot = shot;
  miscue_shot.tip_offset.side = cue.stable_tip_offset + 0.1;
  const CueStrikeResult miscue =
      apply_cue_strike(miscued, miscue_shot, physics, cue);
  expect(miscue.miscue && !miscue.applied,
         "offset beyond the stable contact window is identified as a miscue");
}

std::vector<Ball> create_rack(const TableSpec &table) {
  std::vector<Ball> balls(16);
  balls[0].id = 0;
  balls[0].number = 0;
  balls[0].position = {-0.82, 0.0};
  const std::array<std::array<int, 5>, 5> rack{{
      {{1, 0, 0, 0, 0}},
      {{9, 2, 0, 0, 0}},
      {{3, 8, 10, 0, 0}},
      {{11, 4, 12, 5, 0}},
      {{6, 13, 7, 14, 15}},
  }};
  const std::array<int, 5> row_lengths{{1, 2, 3, 4, 5}};
  std::size_t next_id = 1;
  const double spacing = 2.0 * kBallRadius + 0.00015;
  const double row_step = spacing * std::sqrt(3.0) * 0.5;
  const double foot_x = table.half_length * 0.5;
  for (std::size_t row = 0; row < rack.size(); ++row) {
    for (int slot = 0; slot < row_lengths[row]; ++slot) {
      Ball &ball = balls[next_id];
      ball.id = static_cast<int>(next_id);
      ball.number = rack[row][static_cast<std::size_t>(slot)];
      ball.position = {foot_x + static_cast<double>(row) * row_step,
                       (static_cast<double>(slot) -
                        static_cast<double>(row) * 0.5) * spacing};
      ++next_id;
    }
  }
  return balls;
}

void test_rack_placement_and_numbering() {
  const TableSpec table;
  const std::vector<Ball> balls = create_rack(table);
  expect(balls.size() == 16, "rack contains one cue ball and fifteen object balls");
  expect_near(balls[1].position.x, table.half_length * 0.5, 1.0e-9,
              "rack apex is placed on the foot spot");
  expect(balls[5].number == 8, "eight ball occupies the center of the rack");
  std::array<bool, 16> seen{};
  for (const Ball &ball : balls) {
    expect(ball.number >= 0 && ball.number < static_cast<int>(seen.size()),
           "rack ball number is in the expected range");
    if (ball.number >= 0 && ball.number < static_cast<int>(seen.size())) {
      expect(!seen[static_cast<std::size_t>(ball.number)],
             "rack ball numbers are unique");
      seen[static_cast<std::size_t>(ball.number)] = true;
    }
  }
}

void test_half_ball_cut_angle_is_smooth_at_1e4_radian_spacing() {
  constexpr int point_count = 1601;
  constexpr double first_angle = -0.08;
  constexpr double angle_step = 0.0001;
  constexpr double start_distance = 0.3;
  PhysicsConfig config = quiet_config();
  config.ball_restitution = 1.0;
  const TableSpec table;
  double previous_departure = std::numeric_limits<double>::infinity();
  double maximum_error = 0.0;
  double maximum_error_aim = 0.0;
  double maximum_error_departure = 0.0;
  double maximum_error_expected = 0.0;

  for (int sample = 0; sample < point_count; ++sample) {
    const double aim_angle = first_angle + angle_step * sample;
    Ball cue_ball;
    cue_ball.id = 0;
    cue_ball.position = {-start_distance, 0.0};
    cue_ball.velocity = {std::cos(aim_angle), std::sin(aim_angle)};
    Ball object_ball;
    object_ball.id = 1;
    object_ball.number = 1;
    std::vector<Ball> balls{cue_ball, object_ball};
    std::vector<Event> events;
    Simulator simulator;
    (void)simulator.advance(balls, 0.4, config, table, &events);

    const bool recorded_contact = std::any_of(
        events.begin(), events.end(), [](const Event &event) {
          return event.kind == EventKind::ball_contact && event.ball_a == 0 &&
                 event.ball_b == 1;
        });
    expect(recorded_contact,
           "cut-angle sweep produces a collision for every aim sample");
    expect(balls[1].velocity.length() > 0.1,
           "object ball receives a measurable velocity in each cut sample");
    const double departure =
        std::atan2(balls[1].velocity.z, balls[1].velocity.x);
    const double impact_parameter = start_distance * std::sin(aim_angle);
    const double analytic_departure =
        aim_angle - std::asin(impact_parameter / (2.0 * kBallRadius));
    const double error = std::abs(departure - analytic_departure);
    if (error > maximum_error) {
      maximum_error = error;
      maximum_error_aim = aim_angle;
      maximum_error_departure = departure;
      maximum_error_expected = analytic_departure;
    }
    expect(departure < previous_departure,
           "object-ball departure changes monotonically with a 1e-4 rad aim step");
    previous_departure = departure;
  }

  expect(maximum_error < 1.0e-4,
         "cut-angle output matches analytic curve; max error=" +
             std::to_string(maximum_error) + " at aim=" +
             std::to_string(maximum_error_aim) + " actual=" +
             std::to_string(maximum_error_departure) + " expected=" +
             std::to_string(maximum_error_expected));
  std::cout << "cut_sweep_points=" << point_count
            << " aim_step_radians=" << angle_step
            << " max_departure_error_radians=" << maximum_error << '\n';
}

void benchmark_breaks() {
  constexpr int trials = 7;
  constexpr double simulated_seconds = 4.0;
  constexpr int render_hz = 60;
  const TableSpec table;
  PhysicsConfig physics;
  CueConfig cue;
  for (int trial = 0; trial < trials; ++trial) {
    std::vector<Ball> balls = create_rack(table);
    CueStrikeParameters shot;
    shot.direction = {1.0, 0.0};
    shot.cue_speed = 7.5;
    (void)apply_cue_strike(balls[0], shot, physics, cue);
    Simulator simulator;
    const auto start = std::chrono::steady_clock::now();
    const int frames = static_cast<int>(simulated_seconds * render_hz);
    for (int frame = 0; frame < frames; ++frame) {
      (void)simulator.advance(balls, 1.0 / render_hz, physics, table);
    }
    const auto end = std::chrono::steady_clock::now();
    const double milliseconds =
        std::chrono::duration<double, std::milli>(end - start).count();
    std::cout << "trial=" << trial + 1
              << " simulated_seconds=" << simulated_seconds
              << " wall_ms=" << milliseconds
              << " fixed_ticks=" << simulator.fixed_ticks() << '\n';
  }
}

void run_unit_tests() {
  test_rolling_resistance_and_stopping_distance();
  test_stun_to_roll_reference();
  test_sidespin_decay();
  test_head_on_collision_and_event();
  test_fixed_step_chunking_and_tick_count();
  test_cushion_geometry_and_airborne_clearance();
  test_cushion_time_of_impact();
  test_cue_strike_energy_squirt_and_miscue();
  test_rack_placement_and_numbering();
  test_half_ball_cut_angle_is_smooth_at_1e4_radian_spacing();
  std::cout << "PASS: " << checks << " native core checks\n";
}

} // namespace

int main(int argc, char **argv) {
  try {
    if (argc > 1 && std::string(argv[1]) == "--benchmark") {
      benchmark_breaks();
    } else {
      run_unit_tests();
    }
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
