# Changelog

## [4.5.0](https://github.com/justcarlson/dotfiles/compare/v4.4.1...v4.5.0) (2025-12-26)


### Features

* **opencode:** add YouTube tool and source secrets at startup ([#114](https://github.com/justcarlson/dotfiles/issues/114)) ([7824462](https://github.com/justcarlson/dotfiles/commit/7824462174ea50b2ef5308fc6f6c11673916d6c8))

## [4.4.1](https://github.com/justcarlson/dotfiles/compare/v4.4.0...v4.4.1) (2025-12-26)


### Bug Fixes

* **fish:** add Alt+Backspace and Ctrl+Backspace keybindings ([#112](https://github.com/justcarlson/dotfiles/issues/112)) ([373ef13](https://github.com/justcarlson/dotfiles/commit/373ef1352a7c76dbd1d454402c40a9b65c9b946d)), closes [#111](https://github.com/justcarlson/dotfiles/issues/111)

## [4.4.0](https://github.com/justcarlson/dotfiles/compare/v4.3.0...v4.4.0) (2025-12-24)


### Features

* **opencode:** add Planner-Sisyphus model override ([#109](https://github.com/justcarlson/dotfiles/issues/109)) ([e539ddb](https://github.com/justcarlson/dotfiles/commit/e539ddb152cd4715436416f1fa5ff64db151a1ac))

## [4.3.0](https://github.com/justcarlson/dotfiles/compare/v4.2.0...v4.3.0) (2025-12-23)


### Features

* add multi-shell support with bash/fish selection ([c790d4e](https://github.com/justcarlson/dotfiles/commit/c790d4eeac766c58fe7c22d194a50d7f567c94ec))
* add multi-shell support with bash/fish selection ([9899c5b](https://github.com/justcarlson/dotfiles/commit/9899c5b6eff2971018407aab678c4110a0da616e))


### Bug Fixes

* add shellcheck directive to .bashrc ([a2a0171](https://github.com/justcarlson/dotfiles/commit/a2a017193b1bca99ddbb3c65acca28ad71e76275))
* address code review feedback for shell configuration ([5a98a1a](https://github.com/justcarlson/dotfiles/commit/5a98a1a33dd67936e52f8b597e7c35bbe16523b7))
* correct shellcheck error in secrets_verify_shell ([fadac8d](https://github.com/justcarlson/dotfiles/commit/fadac8d9a7ac286368df5887dcaf9ed8e4ad064f))

## [4.2.0](https://github.com/justcarlson/dotfiles/compare/v4.1.0...v4.2.0) (2025-12-19)


### Features

* **opencode:** enable aggressive truncation ([14e1237](https://github.com/justcarlson/dotfiles/commit/14e12371377b316cf446c36d897eba00ad80d32f))
* **opencode:** enable aggressive truncation for token limit handling ([38f5e8a](https://github.com/justcarlson/dotfiles/commit/38f5e8a2581478c0d98c74a4eaa8c41f087212b4))

## [4.1.0](https://github.com/justcarlson/dotfiles/compare/v4.0.0...v4.1.0) (2025-12-19)


### Features

* add orphan PR blocking workflow ([4f5695c](https://github.com/justcarlson/dotfiles/commit/4f5695c0532447e0bfb309d37832f053c2ed5267))
* enforce issue linking in PRs ([f02f287](https://github.com/justcarlson/dotfiles/commit/f02f2875c83e593e23628683429341608547295d))


### Bug Fixes

* allow release-please PRs to skip orphan check ([3d58f0b](https://github.com/justcarlson/dotfiles/commit/3d58f0b9c385515c9e12a5fabac24b185f787bc1))
* exclude release-please PRs from orphan check ([06b3be6](https://github.com/justcarlson/dotfiles/commit/06b3be668e9114242f06d62a1b66a9b5bdf203e9))

## [4.0.0](https://github.com/justcarlson/dotfiles/compare/v3.10.0...v4.0.0) (2025-12-19)


### ⚠ BREAKING CHANGES

* dev branch is deprecated. Create feature branches from main.

### Code Refactoring

* migrate from dev/main to main-only branch strategy ([0447c9d](https://github.com/justcarlson/dotfiles/commit/0447c9d2bf5026e6f8d8e3eb1b78761236c8aa5a))

## [3.10.0](https://github.com/justcarlson/dotfiles/compare/v3.9.1...v3.10.0) (2025-12-19)


### Features

* add bd (beads) installation to install.sh ([e3b88fa](https://github.com/justcarlson/dotfiles/commit/e3b88fa1ff38ad0b6373ba4328e51dbd5d2da1fb))
* add bd (beads) installation to install.sh ([8911543](https://github.com/justcarlson/dotfiles/commit/8911543aa6df2cf07a4e5bdf25d7f612077ea1b1))
* initialize beads issue tracking ([32faa24](https://github.com/justcarlson/dotfiles/commit/32faa2470518a356a0497924f73b955411142412))
* initialize beads issue tracking for dotfiles repo ([d263a20](https://github.com/justcarlson/dotfiles/commit/d263a20a5b671d39d0943cc7f87b517acf857b50))


### Bug Fixes

* address code review feedback for bd installation ([8940d07](https://github.com/justcarlson/dotfiles/commit/8940d07b80504013e164c4f19d20283da8296d88))

## [3.9.1](https://github.com/justcarlson/dotfiles/compare/v3.9.0...v3.9.1) (2025-12-19)


### Bug Fixes

* **ci:** release claude-code-review optimization ([68f77b6](https://github.com/justcarlson/dotfiles/commit/68f77b66862cb1f751e613a8e90ee3840efcd6b7))
* **ci:** skip claude-code-review for bot PRs and non-code changes ([20b8232](https://github.com/justcarlson/dotfiles/commit/20b8232b499293cce5a84c0c6e7a49324512e460))
* **ci:** skip claude-code-review for bot PRs and non-code changes ([6e628a7](https://github.com/justcarlson/dotfiles/commit/6e628a7e6ca39000f2f9eeb2a779e4ce2cc659e4))

## [3.9.0](https://github.com/justcarlson/dotfiles/compare/v3.8.0...v3.9.0) (2025-12-19)


### Features

* **opencode:** add Sisyphus and librarian agent model configs ([16d5ca3](https://github.com/justcarlson/dotfiles/commit/16d5ca377f1f2d856e6d7d75c6598952f60fbe21))
* **opencode:** add Sisyphus and librarian agent model configs ([fadf72f](https://github.com/justcarlson/dotfiles/commit/fadf72f920ca1d8330330228c7da4112fb66671b))

## [3.8.0](https://github.com/justcarlson/dotfiles/compare/v3.7.4...v3.8.0) (2025-12-17)


### Features

* **opencode:** switch agents to Gemini 3 Flash ([1d36723](https://github.com/justcarlson/dotfiles/commit/1d367239b28cfb6a2d78dbc4bc355e8059f3a75c))
* **opencode:** switch agents to Gemini 3 Flash ([9a60144](https://github.com/justcarlson/dotfiles/commit/9a601448c152a023ef82fa209c665fa467559006))

## [3.7.4](https://github.com/justcarlson/dotfiles/compare/v3.7.3...v3.7.4) (2025-12-17)


### Bug Fixes

* restore oh-my-opencode config and add install automation ([6c5a5c0](https://github.com/justcarlson/dotfiles/commit/6c5a5c05ea44c5aec1ab68a0a8888033dbc88c05))
* restore oh-my-opencode config and add install automation ([8411bf9](https://github.com/justcarlson/dotfiles/commit/8411bf9299930a46d73a31055f2d273594441771))

## [3.7.3](https://github.com/justcarlson/dotfiles/compare/v3.7.2...v3.7.3) (2025-12-17)


### Bug Fixes

* replace exa with tavily for faster MCP startup ([e10558d](https://github.com/justcarlson/dotfiles/commit/e10558df42812f8d4e7548c941f6646e37fe70dc))
* replace exa with tavily for faster MCP startup ([61a6581](https://github.com/justcarlson/dotfiles/commit/61a6581ad15b024ac504349256a878067cae481a))

## [3.7.2](https://github.com/justcarlson/dotfiles/compare/v3.7.1...v3.7.2) (2025-12-17)


### Bug Fixes

* remove tool restrictions from exa MCP config ([c98e9af](https://github.com/justcarlson/dotfiles/commit/c98e9afbf32f7b2f3454c532e0683d90a6f8d321))
* remove tool restrictions from exa MCP config ([6c46866](https://github.com/justcarlson/dotfiles/commit/6c46866751e846dc23e0c527f84b8c73c69f070c))

## [3.7.1](https://github.com/justcarlson/dotfiles/compare/v3.7.0...v3.7.1) (2025-12-17)


### Bug Fixes

* use dynamic version badge to prevent release-please conflicts ([#56](https://github.com/justcarlson/dotfiles/issues/56)) ([380740c](https://github.com/justcarlson/dotfiles/commit/380740c7fee6b4f93c3b49e10e3e3eb0f11aa32a))

## [3.7.0](https://github.com/justcarlson/dotfiles/compare/v3.6.0...v3.7.0) (2025-12-17)


### Features

* add path-based CI filtering to skip tests for docs-only changes ([#49](https://github.com/justcarlson/dotfiles/issues/49)) ([#50](https://github.com/justcarlson/dotfiles/issues/50)) ([6dd16d3](https://github.com/justcarlson/dotfiles/commit/6dd16d3bed06cb65a9b9e7abb89f6d13cc0ef9b2)), closes [#37](https://github.com/justcarlson/dotfiles/issues/37)

## [3.6.0](https://github.com/justcarlson/dotfiles/compare/v3.5.0...v3.6.0) (2025-12-17)


### Features

* add automated stale branch cleanup ([51dd401](https://github.com/justcarlson/dotfiles/commit/51dd401b2a46564f60c9e4221b076b4051c84ec4))
* add automated stale branch cleanup workflow ([#45](https://github.com/justcarlson/dotfiles/issues/45)) ([e570f82](https://github.com/justcarlson/dotfiles/commit/e570f8299f8549246f855b6903cb72b95407ee31))


### Bug Fixes

* correct version badge format for release-please ([#40](https://github.com/justcarlson/dotfiles/issues/40)) ([feaf98a](https://github.com/justcarlson/dotfiles/commit/feaf98a0aca4178b80c203e5f10cd4dc71810f49))
* correct version badge format for shields.io ([2a38cbd](https://github.com/justcarlson/dotfiles/commit/2a38cbd41ab293f97e71a5bc2667f7da31a8e6a2))
* use PAT for release-please to trigger CI on PR updates ([c1adfc2](https://github.com/justcarlson/dotfiles/commit/c1adfc252698ccf4a19846c923c057a5973e0ea2))
* use PAT for release-please to trigger CI on PR updates ([#47](https://github.com/justcarlson/dotfiles/issues/47)) ([87caa55](https://github.com/justcarlson/dotfiles/commit/87caa55f102de076f395ce07959118f67aa2ea43))

## [3.5.0](https://github.com/justcarlson/dotfiles/compare/v3.4.0...v3.5.0) (2025-12-16)


### Features

* add automated release workflow with Release Please ([#36](https://github.com/justcarlson/dotfiles/issues/36)) ([832d86a](https://github.com/justcarlson/dotfiles/commit/832d86a2b8dfcca657134d2495c4e78286910e9d))
