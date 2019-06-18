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
  "*": {
    "mouse": 6.0,
    "trackpad": 1.0
  },
  "com.googlecode.iterm2": {
    "mouse": 4.0,
    "touchpad": 0.85
  },
  "Xcode": {
    "mouse": 7.0
  }
}
```

For each app, specify the bundle identifier (like `com.apple.dt.Xcode`) or
localized app name (like `Xcode`) as the key, then an object of devices to
change the acceleration of. There are only two devices:

- `mouse`
- `trackpad`

A value of `-1.0` (a special case which is transformed to `65535.0`)
effectively disables acceleration for that device.

The `*` "app" is special--it acts as the default acceleration profile that is
used when a specific one can't be found for an app.

Acceleration speeds are retained from the value they were last set to. In other
words, if you don't specify a speed, the previous speed will be kept. The
correlating speed value from the default rule won't be used.
