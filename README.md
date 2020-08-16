## Supported OSes

* Android
* MacOS
* Windows

To see exactly what features are supported on each platform, please [see](https://github.com/certaintls/certaintls.app/wiki/Supported-Features-on-Different-OS).

## Develope

### IDE
1. Install [VSCode](https://code.visualstudio.com/) and [Flutter plugin](https://flutter.dev/docs/development/tools/vs-code)

### General steps:
1. Install [Flutter framework](https://flutter.dev/docs/get-started/install)
1. Clone this respository
1. Clone [shared_preferences](https://pub.dev/packages/shared_preferences) [patched](https://github.com/flutter/plugins/pull/2631) version: `git clone --branch shared git@github.com:franciscojma86/plugins.git --depth 1`. After the clone, the `plugins` folder should be in the same folder as this project (not inside this project). This step will no longer be needed once the PR is merged in the upstream.
1. Copy [example.env](https://github.com/certaintls/certaintls.app/blob/master/example.env) to `.env` in the same folder. You will need the secrets from [CertainTLS backend project](https://github.com/certaintls/certaintls.backend)

### Requirements:
1. Read the official flutter [desktop support requirements](https://flutter.dev/desktop#requirements) first
1. Develop on Linux: you will need an Android simulator or an actual Android device to run only Android builds.
2. Develop on MacOS: besides the vscode you installed, you will also need to install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12) to build the MacOS version of the app. The official flutter
3. Develop on Windows:

### Automated testing:

See https://github.com/certaintls/certaintls.app/wiki/Automated-tests-and-import-certs-to-backend-server

### Cron jobs:

See https://github.com/certaintls/certaintls.app/wiki/Automated-tests-and-import-certs-to-backend-server (same as above, will spin off in the near future)

## Support:

Please [file an issue](https://github.com/certaintls/certaintls.app/issues).

## Code contribution:

1. Clone this repository into your own project.
2. Do the work
3. Create a Pull Request against this repository. For more details, please see [GitHub - Contributing to a Project](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project)

