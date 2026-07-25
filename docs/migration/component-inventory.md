# Starry UI 组件迁移清单（component-inventory）

> 本文件为 **Phase 1 权威组件清单**，由对主项目 `Starry-Flutter-Frontend/lib` 的静态扫描证据生成（脚本：按 `class X extends <WidgetBase>` 枚举 Widget 类，按 import 依赖推断耦合信号）。**零代码改动**。

## 1. 迁移漏斗（证据口径）

| 阶段 | 数量 | 口径 |
|---|---:|---|
| Widget 类总数 | 608 | 继承 StatelessWidget / StatefulWidget / ConsumerWidget / ConsumerStatefulWidget / HookWidget / HookConsumerWidget / ImplicitlyAnimatedWidget（排除 `*.g.dart`、`*.freezed.dart`） |
| public（非下划线私有类） | 295 | 类名不以 `_` 开头 |
| 迁移候选 | 169 | public 且耦合等级 ∈ A/B（排除 C 业务耦合、D 重 IO） |
| — 其中 A（纯展示） | 164 | import 无 state/nav/business/io 信号 |
| — 其中 B（轻耦合） | 5 | 仅消费 state/nav，无业务模型或 IO |

> 说明：本表数字为基于 import 信号的**证据化重新推导**，用以取代规划阶段的估算（131/27/16）。差异来自口径可机械复现：耦合等级由依赖 import 判定，而非人工估计。C/D 组件（业务/IO 耦合）不在本清单迁移范围内，逻辑保留主项目。

## 2. 分类维度定义

**耦合等级（A/B/C/D）**——按 import 依赖信号机械判定：

- **A 纯展示**：无状态管理（riverpod/provider/bloc）、无导航、无业务（data/domain/repository/service/model/notifier/controller）、无 IO（dio/http/prefs/sqflite/hive/websocket）import。
- **B 轻耦合**：仅消费状态或导航 import，无业务模型 / IO。
- **C 业务耦合**：import 业务/领域/模型/仓储层 —— 不迁移，逻辑留主项目。
- **D 重 IO**：import 网络/持久化/连接性 —— 不迁移。

**设计系统价值**：`foundation`（基础原语：按钮/输入/卡片/主题）、`pattern`（组合模式：反馈/布局/设置族/外壳）、`business-specific`（业务特化：chat/cluster/auth 等功能内组件）。

**目标去向**：`public-API`（进 `lib/starry_ui.dart` barrel）、`internal-stable`（进 `lib/src/`，库内稳定但不对外导出）、`keep-in-main`（保留主项目，不迁移）。

> 纪律：**PURE(A) ≠ 必进 public-API**。去向由「耦合 + 设计价值」二维裁定；业务特化组件即便是 A 级纯展示，默认 `keep-in-main`，仅当确认其为通用原语时才上迁。

## 3. 候选组件分布

| 设计价值 | 数量 |  | 目标去向 | 数量 |
|---|---:|---|---|---:|
| foundation | 17 |  | public-API | 32 |
| pattern | 81 |  | internal-stable | 66 |
| business-specific | 71 |  | keep-in-main | 71 |

## 4. 组件明细

> 每行三属性齐全：耦合等级 / 设计价值 / 目标去向。去向为**首轮提案**，在各组件真实迁移时（Phase 2–4）逐一复核确认。

### feature: `core` （97）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `ActionOptionCard` | `lib/core/widgets/pullup/action_option_card.dart` | A | pattern | internal-stable |
| `AiRoundActionButton` | `lib/core/widgets/bottom_chrome.dart` | A | pattern | internal-stable |
| `AiloreAnimatedControlShell` | `lib/core/widgets/settings/ailore_control_shell.dart` | A | pattern | internal-stable |
| `AiloreAssetImageCard` | `lib/core/widgets/settings/ailore_asset_image_card.dart` | A | pattern | internal-stable |
| `AiloreControlShell` | `lib/core/widgets/settings/ailore_control_shell.dart` | A | pattern | internal-stable |
| `AiloreInputField` | `lib/core/widgets/settings/ailore_input_field.dart` | A | pattern | internal-stable |
| `AiloreMessageList` | `lib/core/components/feedback/ailore_message_list.dart` | A | pattern | public-API |
| `AilorePersonaActionChip` | `lib/core/widgets/settings/ailore_persona_showcase.dart` | A | pattern | internal-stable |
| `AilorePersonaSegmentedTabs` | `lib/core/widgets/settings/ailore_persona_showcase.dart` | A | pattern | internal-stable |
| `AilorePersonaSummaryCard` | `lib/core/widgets/settings/ailore_persona_showcase.dart` | A | pattern | internal-stable |
| `AilorePressScale` | `lib/core/widgets/settings/ailore_interaction_presets.dart` | A | pattern | internal-stable |
| `AiloreResourceReferenceCard` | `lib/core/widgets/settings/ailore_resource_reference_card.dart` | A | pattern | internal-stable |
| `AiloreRoundIconShell` | `lib/core/widgets/settings/ailore_control_shell.dart` | A | pattern | internal-stable |
| `AiloreSelectedHighlight` | `lib/core/widgets/settings/ailore_interaction_presets.dart` | A | pattern | internal-stable |
| `AiloreSlidableDrawer` | `lib/core/widgets/slidable/ailore_slidable_drawer.dart` | A | pattern | internal-stable |
| `AiloreSlider` | `lib/core/widgets/settings/ailore_slider.dart` | A | pattern | internal-stable |
| `AiloreSwitch` | `lib/core/widgets/settings/ailore_switch.dart` | A | pattern | internal-stable |
| `AppBadge` | `lib/core/components/base/app_badge.dart` | A | foundation | public-API |
| `AppButton` | `lib/core/components/base/buttons/app_button.dart` | A | foundation | public-API |
| `AppChip` | `lib/core/components/base/app_chip.dart` | A | foundation | public-API |
| `AppDockBar` | `lib/core/widgets/app_dock_bar.dart` | A | pattern | internal-stable |
| `AppHubCategoryBar` | `lib/core/widgets/app_hub_header.dart` | A | pattern | internal-stable |
| `AppHubHeader` | `lib/core/widgets/app_hub_header.dart` | A | pattern | internal-stable |
| `AppHubHeaderAvatarLeading` | `lib/core/widgets/app_hub_header.dart` | A | pattern | internal-stable |
| `AppHubTopBar` | `lib/core/widgets/app_hub_header.dart` | A | pattern | internal-stable |
| `AppIconButton` | `lib/core/components/base/buttons/app_icon_button.dart` | A | foundation | public-API |
| `AppMediaImage` | `lib/core/widgets/images/app_media_image.dart` | A | pattern | internal-stable |
| `AppMediaPlaceholder` | `lib/core/widgets/images/app_media_placeholder.dart` | A | pattern | internal-stable |
| `AppOverlayBackground` | `lib/core/theme/app_background.dart` | A | foundation | public-API |
| `AppShellSideRail` | `lib/core/widgets/app_shell_side_rail.dart` | B | pattern | internal-stable |
| `AppTextButton` | `lib/core/components/base/buttons/text_button_widget.dart` | A | foundation | public-API |
| `AppTextField` | `lib/core/components/base/inputs/app_text_field.dart` | A | foundation | public-API |
| `AssetRefCircleAvatar` | `lib/core/widgets/images/asset_ref_circle_avatar.dart` | A | pattern | internal-stable |
| `AttachmentGridPopup` | `lib/core/widgets/attachment_grid_popup.dart` | A | pattern | internal-stable |
| `BaseCard` | `lib/core/components/base/cards/base_card.dart` | A | foundation | public-API |
| `BottomChromeDivider` | `lib/core/widgets/bottom_chrome.dart` | A | pattern | internal-stable |
| `BottomChromeSurface` | `lib/core/widgets/bottom_chrome.dart` | A | pattern | internal-stable |
| `BottomSheetHandle` | `lib/core/widgets/bottom_sheet_handle.dart` | A | pattern | internal-stable |
| `BottomSheetWrapper` | `lib/core/widgets/bottom_sheet_handle.dart` | A | pattern | internal-stable |
| `CachedAvatar` | `lib/core/components/base/cached_avatar.dart` | A | foundation | public-API |
| `CapsuleSelector` | `lib/core/widgets/capsule_selector.dart` | A | pattern | internal-stable |
| `ConfigurableBackground` | `lib/core/widgets/backgrounds/configurable_background.dart` | A | pattern | internal-stable |
| `EditTextDialog` | `lib/core/widgets/edit_text_dialog.dart` | A | pattern | internal-stable |
| `EmojiText` | `lib/core/theme/emoji_text.dart` | A | foundation | public-API |
| `EmptyState` | `lib/core/components/feedback/empty_state.dart` | A | pattern | public-API |
| `ErrorScaffold` | `lib/core/widgets/error_scaffold.dart` | A | pattern | internal-stable |
| `ErrorWidget` | `lib/core/errors/error_widget.dart` | A | foundation | public-API |
| `ExpandableCard` | `lib/core/components/base/cards/expandable_card.dart` | A | foundation | public-API |
| `ExternalLinkRedirectPage` | `lib/core/routing/external_link_redirect_page.dart` | A | foundation | public-API |
| `FeedBookmarkButton` | `lib/core/widgets/feed/feed_card_primitives.dart` | A | pattern | internal-stable |
| `FeedMediaStage` | `lib/core/widgets/feed/feed_card_primitives.dart` | A | pattern | internal-stable |
| `FeedMetricBar` | `lib/core/widgets/feed/feed_card_primitives.dart` | A | pattern | internal-stable |
| `FeedMetricButton` | `lib/core/widgets/feed/feed_card_primitives.dart` | A | pattern | internal-stable |
| `FeedTypePill` | `lib/core/widgets/feed/feed_card_primitives.dart` | A | pattern | internal-stable |
| `FullScreenLoadingIndicator` | `lib/core/components/feedback/loading_indicator.dart` | A | pattern | public-API |
| `GlobalPopupHost` | `lib/core/overlays/global_popup.dart` | A | pattern | internal-stable |
| `HeaderPagedListSurface` | `lib/core/widgets/header_paged_list_surface.dart` | A | pattern | internal-stable |
| `InputHelperToolbar` | `lib/core/widgets/inputs/input_helper_toolbar.dart` | A | pattern | internal-stable |
| `KeyboardStableScaffold` | `lib/core/widgets/keyboard_stable_scaffold.dart` | A | pattern | internal-stable |
| `LabeledImageCapsule` | `lib/core/widgets/labeled_image_capsule.dart` | A | pattern | internal-stable |
| `LabeledInputGroupCard` | `lib/core/widgets/settings/labeled_input_group_card.dart` | B | pattern | internal-stable |
| `LoadingIndicator` | `lib/core/components/feedback/loading_indicator.dart` | A | pattern | public-API |
| `MasonryFeedCardShell` | `lib/core/widgets/feed/feed_card_primitives.dart` | A | pattern | internal-stable |
| `MaterialSymbol` | `lib/core/widgets/material_symbol.dart` | A | pattern | internal-stable |
| `MultiRectPopup` | `lib/core/widgets/multi_rect_popup.dart` | A | pattern | internal-stable |
| `PageTopBar` | `lib/core/components/layout/app_bar.dart` | A | pattern | public-API |
| `PageWrapper` | `lib/core/components/layout/page_wrapper.dart` | A | pattern | public-API |
| `PrimaryActionButton` | `lib/core/components/base/buttons/primary_action_button.dart` | A | foundation | public-API |
| `PrimaryButton` | `lib/core/components/base/buttons/primary_button.dart` | A | foundation | public-API |
| `PulsingWidget` | `lib/core/components/feedback/looping_animations.dart` | A | pattern | public-API |
| `RotatingWidget` | `lib/core/components/feedback/looping_animations.dart` | A | pattern | public-API |
| `ScalingWidget` | `lib/core/components/feedback/looping_animations.dart` | A | pattern | public-API |
| `SearchCapsule` | `lib/core/widgets/search_capsule.dart` | A | pattern | internal-stable |
| `SearchInput` | `lib/core/components/base/inputs/search_input.dart` | A | foundation | public-API |
| `SecondaryButton` | `lib/core/components/base/buttons/secondary_button.dart` | A | foundation | public-API |
| `SectionHeader` | `lib/core/widgets/section_header.dart` | A | pattern | internal-stable |
| `SectionHeaderWithDivider` | `lib/core/widgets/section_header.dart` | A | pattern | internal-stable |
| `SegmentedThree` | `lib/core/widgets/settings/segmented_three.dart` | A | pattern | internal-stable |
| `SettingsGroupAction` | `lib/core/widgets/settings/settings_group_card.dart` | A | pattern | internal-stable |
| `SettingsGroupCard` | `lib/core/widgets/settings/settings_group_card.dart` | A | pattern | internal-stable |
| `SettingsGroupDivider` | `lib/core/widgets/settings/settings_group_card.dart` | A | pattern | internal-stable |
| `SettingsHeaderBlock` | `lib/core/widgets/settings/settings_header_block.dart` | A | pattern | internal-stable |
| `SettingsItem` | `lib/core/widgets/settings/settings_item.dart` | A | pattern | internal-stable |
| `SettingsSliderTile` | `lib/core/widgets/settings/settings_slider_tile.dart` | A | pattern | internal-stable |
| `ShellAwareBottomSheetContent` | `lib/core/widgets/shell_aware_overlay_content.dart` | A | pattern | internal-stable |
| `ShellAwareContent` | `lib/core/widgets/shell_aware_content.dart` | A | pattern | internal-stable |
| `ShellAwareDialogContent` | `lib/core/widgets/shell_aware_overlay_content.dart` | A | pattern | internal-stable |
| `SkeletonOrContent` | `lib/core/components/feedback/skeleton_or_content.dart` | A | pattern | public-API |
| `SliverPageTopBar` | `lib/core/components/layout/sliver_page_top_bar.dart` | A | pattern | public-API |
| `SliverSkeletonOrContent` | `lib/core/components/feedback/skeleton_or_content.dart` | A | pattern | public-API |
| `StarryCachedImage` | `lib/core/images/starry_cached_image.dart` | A | pattern | internal-stable |
| `StarryGlassPanel` | `lib/core/components/layout/starry_glass_panel.dart` | A | pattern | public-API |
| `StarryGradientFallback` | `lib/core/components/layout/starry_immersive_background.dart` | A | pattern | public-API |
| `StarryImmersiveBackground` | `lib/core/components/layout/starry_immersive_background.dart` | A | pattern | public-API |
| `TabsSearchHeader` | `lib/core/widgets/tabs_search_header.dart` | A | pattern | internal-stable |
| `TagInput` | `lib/core/widgets/inputs/tag_input.dart` | A | pattern | internal-stable |
| `TopBarAddButton` | `lib/core/widgets/top_bar_add_button.dart` | A | pattern | internal-stable |

### feature: `chat` （37）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `ActionButton` | `lib/features/chat/presentation/widgets/message_actions/action_button.dart` | A | business-specific | keep-in-main |
| `AiActionPopupLayer` | `lib/features/chat/presentation/widgets/ai_action_popup_layer.dart` | A | business-specific | keep-in-main |
| `AssistantLaneDecoration` | `lib/features/chat/presentation/widgets/canonical_bubbles/assistant_header.dart` | A | business-specific | keep-in-main |
| `AttachmentPreviewChip` | `lib/features/chat/presentation/widgets/attachment_preview_chip.dart` | A | business-specific | keep-in-main |
| `BreathingDot` | `lib/features/chat/presentation/widgets/breathing_dot.dart` | A | business-specific | keep-in-main |
| `ChatAssistantHeader` | `lib/features/chat/presentation/widgets/canonical_bubbles/assistant_header.dart` | A | business-specific | keep-in-main |
| `ChatBubbleContainer` | `lib/features/chat/presentation/widgets/chat_bubble/chat_bubble_container.dart` | A | business-specific | keep-in-main |
| `ChatBubbleFrame` | `lib/features/chat/presentation/widgets/chat_bubble/chat_bubble_frame.dart` | A | business-specific | keep-in-main |
| `ChatBubbleSurface` | `lib/features/chat/presentation/widgets/chat_bubble/chat_bubble_surface.dart` | A | business-specific | keep-in-main |
| `ChatContentLayer` | `lib/features/chat/presentation/widgets/chat_content_layer.dart` | A | business-specific | keep-in-main |
| `ChatDisplayItemTile` | `lib/features/chat/presentation/widgets/chat_display_item_tile.dart` | A | business-specific | keep-in-main |
| `ChatForegroundLayer` | `lib/features/chat/presentation/widgets/chat_foreground_layer.dart` | A | business-specific | keep-in-main |
| `ChatMainPage` | `lib/features/chat/presentation/pages/chat_main_page.dart` | A | business-specific | keep-in-main |
| `ChatMediaGrid` | `lib/features/chat/presentation/widgets/canonical_bubbles/media_grid.dart` | A | business-specific | keep-in-main |
| `ChatMessageList` | `lib/features/chat/presentation/widgets/chat_message_list.dart` | A | business-specific | keep-in-main |
| `ChatRichContent` | `lib/features/chat/presentation/widgets/canonical_bubbles/chat_rich_content.dart` | A | business-specific | keep-in-main |
| `ChatSceneLayers` | `lib/features/chat/presentation/widgets/chat_scene_layers.dart` | A | business-specific | keep-in-main |
| `ChatSessionListSurface` | `lib/features/chat/presentation/widgets/session_list/chat_session_list_surface.dart` | A | business-specific | keep-in-main |
| `ChatSessionSection` | `lib/features/chat/presentation/widgets/session_list/chat_session_section.dart` | A | business-specific | keep-in-main |
| `ChatTab` | `lib/features/chat/presentation/pages/chat_settings/tabs/chat_tab.dart` | A | business-specific | keep-in-main |
| `ChatTextBubble` | `lib/features/chat/presentation/widgets/canonical_bubbles/text_bubble.dart` | A | business-specific | keep-in-main |
| `ChatToolBubble` | `lib/features/chat/presentation/widgets/canonical_bubbles/tool_bubble.dart` | A | business-specific | keep-in-main |
| `EventBanner` | `lib/features/chat/presentation/widgets/canonical_bubbles/event_banner.dart` | A | business-specific | keep-in-main |
| `GradientChip` | `lib/features/chat/presentation/widgets/gradient_chip.dart` | A | business-specific | keep-in-main |
| `GradientEditor` | `lib/features/chat/presentation/widgets/gradient_editor.dart` | A | business-specific | keep-in-main |
| `InputBar` | `lib/features/chat/presentation/widgets/input_bar.dart` | A | business-specific | keep-in-main |
| `MessageBubble` | `lib/features/chat/presentation/widgets/message_bubble.dart` | A | business-specific | keep-in-main |
| `ModelTab` | `lib/features/chat/presentation/pages/chat_settings/tabs/model_tab.dart` | A | business-specific | keep-in-main |
| `PlannerBubble` | `lib/features/chat/presentation/widgets/planner_bubble.dart` | A | business-specific | keep-in-main |
| `RequiresActionBubble` | `lib/features/chat/presentation/widgets/canonical_bubbles/requires_action_bubble.dart` | A | business-specific | keep-in-main |
| `SearchBarWithButton` | `lib/features/chat/presentation/widgets/search_bar_with_button.dart` | A | business-specific | keep-in-main |
| `SettingItem` | `lib/features/chat/presentation/widgets/setting_item.dart` | A | business-specific | keep-in-main |
| `SystemPill` | `lib/features/chat/presentation/widgets/canonical_bubbles/system_pill.dart` | A | business-specific | keep-in-main |
| `ThinkingDisclosure` | `lib/features/chat/presentation/widgets/components/thinking_disclosure.dart` | A | business-specific | keep-in-main |
| `TimeSeparator` | `lib/features/chat/presentation/widgets/time_separator.dart` | A | business-specific | keep-in-main |
| `TypingIndicatorBubble` | `lib/features/chat/presentation/widgets/canonical_bubbles/typing_indicator_bubble.dart` | A | business-specific | keep-in-main |
| `UnreadBadge` | `lib/features/chat/presentation/widgets/unread_badge.dart` | A | business-specific | keep-in-main |

### feature: `cluster` （16）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `ArticleEditorContentBlocks` | `lib/features/cluster/presentation/pages/site/article_editor/article_editor_content_blocks.dart` | A | business-specific | keep-in-main |
| `ArticleEditorStickyToolbar` | `lib/features/cluster/presentation/pages/site/article_editor/article_editor_toolbar.dart` | A | business-specific | keep-in-main |
| `ClusterArticleBodyImages` | `lib/features/cluster/presentation/widgets/cluster_media.dart` | A | business-specific | keep-in-main |
| `ClusterArticleCover` | `lib/features/cluster/presentation/widgets/cluster_media.dart` | A | business-specific | keep-in-main |
| `ClusterDetailVisualFallback` | `lib/features/cluster/presentation/widgets/cluster_responsive_detail_shell.dart` | B | business-specific | keep-in-main |
| `ClusterMediaGrid` | `lib/features/cluster/presentation/widgets/cluster_media.dart` | A | business-specific | keep-in-main |
| `ClusterPage` | `lib/features/cluster/presentation/pages/cluster_page.dart` | A | business-specific | keep-in-main |
| `ClusterRelationItem` | `lib/features/cluster/presentation/widgets/cluster_relation_item.dart` | A | business-specific | keep-in-main |
| `ClusterResponsiveDetailShell` | `lib/features/cluster/presentation/widgets/cluster_responsive_detail_shell.dart` | B | business-specific | keep-in-main |
| `EditorCardShell` | `lib/features/cluster/presentation/widgets/editor/editor_card_shell.dart` | A | business-specific | keep-in-main |
| `EditorExitDialog` | `lib/features/cluster/presentation/widgets/editor/editor_exit_dialog.dart` | A | business-specific | keep-in-main |
| `EditorImageGrid` | `lib/features/cluster/presentation/widgets/editor/editor_image_grid.dart` | A | business-specific | keep-in-main |
| `EditorImageThumb` | `lib/features/cluster/presentation/widgets/editor/editor_image_grid.dart` | A | business-specific | keep-in-main |
| `EditorPillChip` | `lib/features/cluster/presentation/widgets/editor/editor_pill_chip.dart` | A | business-specific | keep-in-main |
| `EditorPublishBar` | `lib/features/cluster/presentation/widgets/editor/editor_publish_bar.dart` | A | business-specific | keep-in-main |
| `EditorSectionHeader` | `lib/features/cluster/presentation/widgets/editor/editor_section_header.dart` | A | business-specific | keep-in-main |

### feature: `auth` （7）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `AgreementRow` | `lib/features/auth/presentation/widgets/agreement_row.dart` | A | business-specific | keep-in-main |
| `AuthResponsiveScaffold` | `lib/features/auth/presentation/widgets/auth_responsive_scaffold.dart` | A | business-specific | keep-in-main |
| `CompactAuthScaffold` | `lib/features/auth/presentation/widgets/auth_responsive_scaffold.dart` | A | business-specific | keep-in-main |
| `CountryCodeChip` | `lib/features/auth/presentation/widgets/country_code_chip.dart` | A | business-specific | keep-in-main |
| `GradientBackground` | `lib/features/auth/presentation/widgets/gradient_background.dart` | A | business-specific | keep-in-main |
| `OtpBoxes` | `lib/features/auth/presentation/widgets/otp_boxes.dart` | A | business-specific | keep-in-main |
| `WideAuthScaffold` | `lib/features/auth/presentation/widgets/auth_responsive_scaffold.dart` | A | business-specific | keep-in-main |

### feature: `assets` （2）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `AssetGlass` | `lib/features/assets/presentation/widgets/asset_surface_theme.dart` | A | business-specific | keep-in-main |
| `AssetSurfaceBackground` | `lib/features/assets/presentation/widgets/asset_surface_theme.dart` | A | business-specific | keep-in-main |

### feature: `settings` （2）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `LobeHubProviderIcon` | `lib/features/settings/llm/widgets/lobehub_provider_icon.dart` | A | business-specific | keep-in-main |
| `SettingsPage` | `lib/features/settings/presentation/pages/settings_page.dart` | B | business-specific | keep-in-main |

### feature: `creator` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `LocalAssetActionSheet` | `lib/features/creator/presentation/widgets/local_asset_action_sheet.dart` | A | business-specific | keep-in-main |

### feature: `dev` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `ComponentGalleryPage` | `lib/features/dev/presentation/pages/component_gallery_page.dart` | A | business-specific | keep-in-main |

### feature: `profile` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `WindowsCameraCapturePage` | `lib/features/profile/presentation/pages/windows_camera_capture_page.dart` | A | business-specific | keep-in-main |

### feature: `regex` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `RegexToolPage` | `lib/features/regex/presentation/pages/regex_tool_page.dart` | A | business-specific | keep-in-main |

### feature: `splash` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `SplashPlaceholderPage` | `lib/features/splash/presentation/pages/splash_placeholder_page.dart` | A | business-specific | keep-in-main |

### feature: `square` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `RenameDialog` | `lib/features/square/presentation/widgets/rename_dialog.dart` | A | business-specific | keep-in-main |

### feature: `starry_ai` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `StarryAIPage` | `lib/features/starry_ai/presentation/pages/starry_ai_page.dart` | A | business-specific | keep-in-main |

### feature: `typography.dart` （1）

| 组件 | 源文件 | 耦合 | 设计价值 | 目标去向 |
|---|---|:--:|---|---|
| `MixedText` | `lib/typography.dart` | A | pattern | internal-stable |

## 5. 已知修正项

- **AppShellSideRail 归 A/B 可迁**：其外层 app shell（承载路由/状态）保留主项目，但侧栏纯展示部分可下迁；如扫描未单列，Phase 2 拆分时按此裁定。
- 扫描以 import 为证据，个别组件可能存在**未经 import 的隐式耦合**（如通过 InheritedWidget 读取），迁移前需人工确认。

---
_本清单由静态扫描生成，作为迁移规划权威依据；组件代码未作任何改动。_
