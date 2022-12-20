Changelog for the gruf-prometheus gem.

### Pending Release

### 2.3.1

- Ensure ActiveRecord collector is started on gruf hook

### 2.3.0

- Add server collector and interceptor for measuring server failures
- Add client collector and interceptor for measuring client failures

### 2.2.0

- Add Ruby 3.1 support
- Drop support for Ruby 2.6
- Add CircleCI test suite for Ruby 3.1

### 2.1.0

- Add Ruby 3 support

### 2.0.0

- Add server interceptor for measuring counters/histograms for server metrics
- Add client interceptor for measuring counters/histograms for client metrics
- Bump Rubocop to 1.1, remove development dependency on null_logger

### 1.3.0

- Drop Ruby < 2.6 support
- Bump bc-prometheus-ruby dependency to 0.3
- Adds support for Ruby 2.7
- Adds help script for testing locally

### 1.2.0

- Add the ability to have custom collectors and type collectors

### 1.1.0

- Refactor collector/type collector to utilize new base abstractions
- Bump bc-prometheus-ruby dependency

### 1.0.2

- Bump bc-prometheus-ruby dependency

### 1.0.1

- Bump bc-prometheus-ruby dependency

### 1.0.0

- *Breaking Changes* Move all prometheus core dependencies to bc-prometheus-ruby

### 0.0.2

- Cleaner starting of the gruf server and collectors
- Improved logging and visibility around starting/stopping of collectors/server

### 0.0.1

- Initial public release
