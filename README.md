# Fluid Admin

Fluid Admin is a custom Roblox admin panel made to be **simple** and **fast**.

## Features

- Ban, Unban, Music and Edit Stats.
- An intuitive and nice looking UI.
- Ability to log data on Discord.
- High security on server side.

## Installation

**⚠️ The project is currently in development and the only way to install it is by building the project with a plugin like [Rojo](https://rojo.space/). If you plan on using this in your game, consider the fact of updating it everytime a new version is out.**

After the project is installed on your place, you have to configure it.
You can find a script called Constants inside `Shared -> Utility` which is the main configuration file.

| Config Name | Description | Default |
|-------------|-------------|---------|
| `SUBMIT_DELAY` | The delay in seconds after each submit operation | `10` |
| `MAX_DAYS` | The max number that can be put in the days field | `365` |
| `MAX_PERM_DAYS` | The number that when exceeded, the ban becomes permanent | `30` |
| `MAX_LIMITED_DAYS` | The max number that non-HRs can put in the days field | `14` |
| `MAX_PROOFS` | The max number of proofs that can be added | `5` |
| `MAX_REASON_LENGTH` | The max length of the reason that can be submitted. In case the reason exceeds the limit, it's gonna be truncated | `2000` |
| `EMBED_COLOR` | The color in decimal format for the Discord log embed | `6737322` |
| `GROUP_ID` | The group id of the Roblox group | `0` |
| `TRUSTED_RANKS` | An array of the actual staff role ids | `{ 0 }` |
| `HR_RANK` | The role id of your HR rank. HR stands for High Rank, usually it's the rank for admins with more powers. For Fluid Admin, HRs can access permanent bans and unbans | `0` |

To set the Webhook you have to change the StringValue for `ServerScriptService -> AdminServer -> Webhook`.

## Links

- Roblox Model: N/A
- YouTube Tutorial: N/A
- Discord Server: https://discord.gg/ZE5kfrW