#pragma once

#include <array>
#include <cstdint>
#include <vector>

namespace longrail::physics {

inline constexpr double kBallRadius = 0.028575;
inline constexpr double kBallMass = 0.168;
inline constexpr double kBallInertia = 0.4 * kBallMass * kBallRadius * kBallRadius;
inline constexpr double kOffTableTerminalHeight = -0.12;

struct Vec2 {
  double x = 0.0;
  double z = 0.0;

  [[nodiscard]] double length_squared() const;
  [[nodiscard]] double length() const;
  [[nodiscard]] Vec2 normalized() const;
  [[nodiscard]] Vec2 limited(double maximum) const;
  [[nodiscard]] double dot(const Vec2 &other) const;

  Vec2 &operator+=(const Vec2 &other);
  Vec2 &operator-=(const Vec2 &other);
  Vec2 &operator*=(double scalar);
};

Vec2 operator+(Vec2 left, const Vec2 &right);
Vec2 operator-(Vec2 left, const Vec2 &right);
Vec2 operator*(Vec2 value, double scalar);
Vec2 operator*(double scalar, Vec2 value);
Vec2 operator/(Vec2 value, double scalar);

struct Vec3 {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;

  [[nodiscard]] double length_squared() const;
  [[nodiscard]] double length() const;
  [[nodiscard]] Vec3 normalized() const;
  [[nodiscard]] double dot(const Vec3 &other) const;
  [[nodiscard]] Vec3 cross(const Vec3 &other) const;

  Vec3 &operator+=(const Vec3 &other);
  Vec3 &operator-=(const Vec3 &other);
  Vec3 &operator*=(double scalar);
};

Vec3 operator+(Vec3 left, const Vec3 &right);
Vec3 operator-(Vec3 left, const Vec3 &right);
Vec3 operator*(Vec3 value, double scalar);
Vec3 operator*(double scalar, Vec3 value);
Vec3 operator/(Vec3 value, double scalar);

struct Quaternion {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  double w = 1.0;
};

enum class Phase : std::uint8_t {
  in_play,
  airborne,
  falling,
  pocketed,
  off_table,
};

struct Ball {
  int id = 0;
  int number = 0;
  Vec2 position{};
  double height = kBallRadius;
  Vec2 velocity{};
  double vertical_velocity = 0.0;
  Vec3 angular_velocity{};
  Quaternion orientation{};
  Phase phase = Phase::in_play;
  int pocket_id = -1;

  [[nodiscard]] bool is_on_table() const;
  void advance_orientation(double delta_seconds);
  [[nodiscard]] std::array<double, 17> canonical_state() const;
};

struct PhysicsConfig {
  double fixed_step = 1.0 / 480.0;
  double gravity = 9.81;
  double ball_mass = kBallMass;
  double ball_restitution = 0.94;
  double ball_friction = 0.055;
  double cushion_restitution = 0.84;
  double cushion_friction = 0.12;
  double sliding_friction = 0.19;
  double rolling_resistance = 0.012;
  double spinning_friction = 0.0127;
  double sleep_speed_threshold = 0.012;
  double sleep_spin_threshold = 0.08;
  double max_substep_travel_fraction = 0.45;
  int max_collision_iterations = 6;
};

struct CueConfig {
  double mass = 0.52;
  double collision_efficiency = 0.87;
  double effective_end_mass = 0.008;
  double stable_tip_offset = 0.5;
};

struct TipOffset {
  double side = 0.0;
  double vertical = 0.0;

  [[nodiscard]] double length_squared() const;
  [[nodiscard]] double length() const;
};

struct CueStrikeResult {
  bool applied = false;
  bool miscue = false;
  double ball_speed = 0.0;
  double squirt_angle = 0.0;
};

struct RailSegment {
  Vec2 a{};
  Vec2 b{};
  Vec2 inward{};
  bool jaw = false;
};

struct TableSpec {
  double half_length = 1.27;
  double half_width = 0.635;
  double corner_mouth = 0.116;
  double side_mouth = 0.129;
  double pocket_depth = 0.13;
  double cushion_nose_height = 1.27 * kBallRadius;

  [[nodiscard]] std::vector<RailSegment> rail_segments() const;
  [[nodiscard]] std::array<double, 4> corner_mouth_widths() const;
  [[nodiscard]] int pocket_at(const Vec2 &position) const;
  [[nodiscard]] bool outside_table(const Vec2 &position) const;
};

enum class EventKind : std::uint8_t {
  ball_contact,
  cushion_contact,
  jaw_contact,
  pocket_entry,
  pocketed,
  off_table,
  airborne_launch,
  landing,
  slide_to_roll,
  stationary,
};

struct Event {
  double time_seconds = 0.0;
  EventKind kind = EventKind::ball_contact;
  int ball_a = -1;
  int ball_b = -1;
  int surface_id = -1;
  Vec3 position{};
  Vec3 normal{};
  double relative_speed = 0.0;
};

struct CueStrikeParameters {
  Vec2 direction{1.0, 0.0};
  double cue_speed = 0.0;
  TipOffset tip_offset{};
  double cue_elevation = 0.0;
};

CueStrikeResult apply_cue_strike(Ball &ball, const CueStrikeParameters &shot,
                                 const PhysicsConfig &physics,
                                 const CueConfig &cue);

class Simulator {
public:
  [[nodiscard]] std::uint64_t advance(std::vector<Ball> &balls,
                                      double elapsed_seconds,
                                      const PhysicsConfig &config,
                                      const TableSpec &table,
                                      std::vector<Event> *events = nullptr);
  void step_fixed(std::vector<Ball> &balls, double delta_seconds,
                  const PhysicsConfig &config, const TableSpec &table,
                  std::vector<Event> *events = nullptr);
  [[nodiscard]] bool settled(const std::vector<Ball> &balls,
                             const PhysicsConfig &config) const;
  [[nodiscard]] std::uint64_t fixed_ticks() const;
  [[nodiscard]] double simulated_seconds() const;

private:
  double accumulator_ = 0.0;
  double simulated_seconds_ = 0.0;
  std::uint64_t fixed_ticks_ = 0;

  void step_with_rails(std::vector<Ball> &balls, double delta_seconds,
                       const PhysicsConfig &config, const TableSpec &table,
                       const std::vector<RailSegment> &rails,
                       std::vector<Event> *events);
  void integrate_balls(std::vector<Ball> &balls, double delta_seconds,
                       const PhysicsConfig &config, const TableSpec &table,
                       double event_time,
                       std::vector<Event> *events);
  void apply_cloth_friction(Ball &ball, double delta_seconds,
                            const PhysicsConfig &config);
  bool resolve_ball_pair(Ball &first, Ball &second,
                        const Ball &previous_first, const Ball &previous_second,
                        double substep_seconds, const PhysicsConfig &config,
                        double event_time,
                        std::vector<Event> *events);
  bool resolve_rails(Ball &ball, const PhysicsConfig &config,
                     const Ball &previous_ball, double substep_seconds,
                     const TableSpec &table,
                     const std::vector<RailSegment> &rails,
                     double event_time,
                     std::vector<Event> *events);
  void classify_exits(std::vector<Ball> &balls, const TableSpec &table,
                      double event_time, std::vector<Event> *events);
};

} // namespace longrail::physics
