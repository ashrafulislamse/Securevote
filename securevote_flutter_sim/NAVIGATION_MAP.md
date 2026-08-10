# SecureVote Mobile Navigation Map (Flutter Simulation)

This map defines the final navigation model and marks current implementation progress.

## Unified Bottom Tabs (Final Target)

1. Home
2. Explore
3. Votes
4. Alerts
5. Profile

## Screen Visibility Rules

Bottom navigation remains hidden on focused flows (auth, KYC, ballot, and forms).

## Phase-1 Implemented Screens

| Screen ID | Bottom Nav | Status |
|---|---|---|
| welcome_splash | Hidden | Implemented |
| onboarding_1_obsidian_redesign | Hidden | Implemented |
| login_screen | Hidden | Implemented |
| register_screen | Hidden | Implemented |
| kyc_step_1 | Hidden | Implemented |
| home_screen | Hidden (placeholder) | Implemented placeholder |

## Phase-2 Implemented Screens

| Screen ID | Bottom Nav | Status |
|---|---|---|
| kyc_status_pending | Hidden | Implemented |
| home_screen | Visible | Implemented (full) |
| election_search | Visible | Implemented |
| election_details | Hidden | Implemented |
| election_rules | Hidden | Implemented |

## Planned Full Map

| Screen ID | Bottom Nav | Mapped Tab |
|---|---|---|
| welcome_splash | Hidden | - |
| onboarding_1_obsidian_redesign | Hidden | - |
| login_screen | Hidden | - |
| register_screen | Hidden | - |
| kyc_step_1 | Hidden | - |
| kyc_status_pending | Hidden | - |
| home_screen | Visible | Home |
| election_search | Visible | Explore |
| election_details | Hidden | Explore |
| election_rules | Hidden | Explore |
| candidate_details | Hidden | Explore |
| candidate_manifesto | Hidden | Explore |
| compare_candidates | Hidden | Explore |
| ballot_casting | Hidden | Explore |
| review_vote | Hidden | Explore |
| vote_success | Hidden | Explore |
| vote_receipt_obsidian_style | Hidden | Votes |
| my_votes | Visible | Votes |
| election_results_fixed | Hidden | Votes |
| notifications_inbox_obsidian | Visible | Alerts |
| notification_settings | Hidden | Alerts |
| profile_settings_hub_obsidian | Visible | Profile |
| profile_view | Hidden | Profile |
| edit_profile | Hidden | Profile |
| change_password | Hidden | Profile |
| help_support_fixed | Hidden | Profile |

## Functional Flow Summary

1. Current implemented flow: Splash -> Onboarding -> Login/Register -> KYC Step 1 -> KYC Pending -> Home -> Search/Details/Rules.
2. Next phase extends candidate, ballot, vote receipt, alerts, and profile flows.

## Notes

- No real authentication, backend, or live election data is used.
- App is responsive via constrained mobile-width shell with adaptive layout behavior.
- First 5 production-style screens are fully implemented.
