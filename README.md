# AccelerationProfiles

Easily manage custom mouse/trackpad acceleration speeds on a per-app basis with
a JSON file.

![Menubar Screenshot](https://owo.whats-th.is/5983c9.png)

## Configuring

Upon launch, the app will create the configuration for you if non-existent:

`~/Library/Application Support/AccelerationProfiles/config.json`

Sample configuration:

```json
{
  "com.googlecode.iterm2": {
    "mouse": 4.0,
    "touchpad": 0.85
  },
  "Xcode": {
    "mouse": 7.0
  },
  "*": {
    "mouse": 6.0,
    "trackpad": 1.0
  }
}
```

Specify the bundle identifier (like `com.apple.dt.Xcode`) or localized
application name (like `Xcode`) as the key, then a device to acceleration
mapping as the value. Two devices are supported: `mouse` and `trackpad`. They
are both optional and the value is only changed if present. The acceleration
values inherit from the previously set value, not the special default rule.

The `*` rule is special — it acts as a default rule when a specific rule cannot
be found. Remember that this does not work for individual values — the `*` rule
is only processed when a rule for the app you just focused was not found.
