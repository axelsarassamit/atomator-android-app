# Architecture

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.29 |
| SSH Library | dartssh2 |
| State Management | Provider |
| Credential Storage | flutter_secure_storage |
| Host Storage | shared_preferences |
| APK Install | open_filex |
| CI/CD | GitHub Actions |
| Signing | Keystore via GitHub Secrets |

## Project Structure

```
lib/
  main.dart                          Entry point
  theme.dart                         Dark theme config
  models/
    models.dart                      Host, Credentials, SSHResult, JobResult
  services/
    ssh_service.dart                 SSH connection + parallel execution
    storage_service.dart             Encrypted credential + host storage
    command_service.dart             All 55+ commands as static methods
    update_service.dart              GitHub API version check + download
  providers/
    host_provider.dart               Host state, check status, groups
    job_provider.dart                Job tracking, results
  screens/
    home_screen.dart                 Bottom navigation (6 tabs)
    dashboard_screen.dart            Fleet overview + stats
    hosts_screen.dart                Host list with groups
    actions_screen.dart              All remote commands
    terminal_screen.dart             Interactive SSH terminal
    tools_screen.dart                Remote tools + WOL
    settings_screen.dart             Config tab
    update_screen.dart               In-app updates
    debug_screen.dart                Network testing
    about_screen.dart                Creator + links
    manual_screen.dart               In-app guide
    bug_report_screen.dart           Problem reporting
    splash_screen.dart               Launch animation
    job_screen.dart                  Live results view
    setup_screen.dart                First-run wizard
  widgets/
    widgets.dart                     StatusBadge, ActionCard, ResultsList
scripts/
  patch_android.py                   AndroidManifest + NDK + icon patches
  setup_signing.py                   Release keystore configuration
android_manifest/
  AndroidManifest.xml                Pre-built manifest with all permissions
  network_security_config.xml        Cleartext traffic for SSH
assets/images/
  app_icon.png                       App icon (1024x1024)
  splash_logo.png                    Splash screen logo
  atomator_banner.png                Dashboard banner
```

## How Commands Work

1. User taps an action (or opens Install Applications / Performance Settings sub-menu)
2. Group selector shows (if multiple groups)
3. App filters hosts: `sshOpen == true` in selected group
4. For each host: `SSHService.runCommand(host, creds, cmd)`
5. SSH approach: `echo "pass" | sudo -S bash -c "cmd"` via `client.run()` (dartssh2)
6. Each result updates the UI live (via `JobProvider.addResult`)
7. Progress bar shows X/total with OK/FAIL count
8. Completion summary when done

## SSH Implementation Note

All SSH commands use `SSHClient.run()` (dartssh2 convenience method) with the pattern:
```
echo "<password>" | sudo -S bash -c "<command>"
```
This is the confirmed-working approach since v1.4.6. Do not use `SSHClient.execute()` or stdin injection — these approaches break sudo handling in dartssh2.
