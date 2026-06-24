import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../models/user.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/email_verification_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/dashboard/screens/freelancer_dashboard_screen.dart';
import '../../features/dashboard/screens/client_dashboard_screen.dart';
import '../../features/projects/screens/project_list_screen.dart';
import '../../features/projects/screens/find_work_screen.dart';
import '../../features/projects/screens/create_project_screen.dart';
import '../../features/projects/screens/project_detail_screen.dart';
import '../../features/milestones/screens/milestone_list_screen.dart';
import '../../features/milestones/screens/milestone_detail_screen.dart';
import '../../features/milestones/screens/milestone_approval_screen.dart';
import '../../features/tasks/screens/kanban_board_screen.dart';
import '../../features/tasks/screens/task_detail_screen.dart';
import '../../features/tasks/screens/create_task_screen.dart';
import '../../features/deliverables/screens/deliverables_screen.dart';
import '../../features/deliverables/screens/file_preview_screen.dart';
import '../../features/deliverables/screens/upload_deliverable_screen.dart';
import '../../features/chat/screens/inbox_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/chat/screens/new_conversation_screen.dart';
import '../../features/chat/screens/video_call_screen.dart';
import '../../features/payments/screens/invoices_list_screen.dart';
import '../../features/payments/screens/create_invoice_screen.dart';
import '../../features/payments/screens/mock_payment_modal.dart';
import '../../features/payments/screens/wallet_dashboard_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/client_portal/screens/client_portal_home_screen.dart';
import '../../features/time_tracking/screens/time_tracker_screen.dart';
import '../../features/time_tracking/screens/time_logs_screen.dart';
import '../../features/proposals/screens/proposals_list_screen.dart';
import '../../features/proposals/screens/create_proposal_screen.dart';
import '../../features/proposals/screens/proposal_detail_screen.dart';
import '../../features/contracts/screens/contracts_list_screen.dart';
import '../../features/contracts/screens/contract_detail_screen.dart';
import '../../features/financials/screens/expenses_list_screen.dart';
import '../../features/financials/screens/add_expense_screen.dart';
import '../../features/dashboard/screens/calendar_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/dashboard/screens/activity_log_screen.dart';
import '../../features/feedback/screens/feedback_screen.dart';
import '../../features/dashboard/screens/analytics_screen.dart';
import '../../features/dashboard/screens/search_screen.dart';
import '../../features/payments/screens/invoice_detail_screen.dart';
import '../../features/profile/screens/billing_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/support_screen.dart';
import '../../features/profile/screens/team_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/profile/screens/two_factor_auth_screen.dart';
import '../../features/profile/screens/legal_document_screen.dart';
import '../../features/profile/screens/support_chat_screen.dart';
import '../../features/profile/screens/faq_screen.dart';
import '../shell/main_shell.dart';


final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userState = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading && authState.valueOrNull == null) return null;
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/role-select') ||
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation == '/';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      
      if (isLoggedIn && (isAuthRoute || state.matchedLocation == '/onboarding')) {
        if (userState.valueOrNull == null) return null;
        final user = userState.valueOrNull!;
        if (user.role == UserRole.client) {
          return '/client-dashboard';
        } else {
          // Freelancer
          if (user.skills.isEmpty && state.matchedLocation != '/profile-setup') {
            return '/profile-setup';
          }
          return '/dashboard';
        }
      }
      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Auth routes
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/role-select',
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, state) {
          final role = state.extra as UserRole?;
          return SignUpScreen(role: role ?? UserRole.freelancer);
        },
      ),
      GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
          path: '/verify-email',
          builder: (_, __) => const EmailVerificationScreen()),
      GoRoute(
          path: '/profile-setup',
          builder: (_, __) => const ProfileSetupScreen()),

      // Offline
      // GoRoute(path: '/offline', builder: (_, __) => const OfflineScreen()),

      // Main shell (bottom nav)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const FreelancerDashboardScreen(),
          ),
          GoRoute(
            path: '/client-dashboard',
            builder: (_, __) => const ClientDashboardScreen(),
          ),

          // Find Work
          GoRoute(
            path: '/find-work',
            builder: (_, __) => const FindWorkScreen(),
          ),

          // Projects
          GoRoute(
            path: '/projects',
            builder: (_, __) => const ProjectListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateProjectScreen(),
              ),
              GoRoute(
                path: ':projectId',
                builder: (_, state) => ProjectDetailScreen(
                  projectId: state.pathParameters['projectId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'milestones',
                    builder: (_, state) => MilestoneListScreen(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'tasks',
                    builder: (_, state) => KanbanBoardScreen(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'deliverables',
                    builder: (_, state) => DeliverablesScreen(
                      projectId: state.pathParameters['projectId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Milestones
          GoRoute(
            path: '/milestones/:milestoneId',
            builder: (_, state) => MilestoneDetailScreen(
              milestoneId: state.pathParameters['milestoneId']!,
            ),
          ),
          GoRoute(
            path: '/milestones/:milestoneId/approve',
            builder: (_, state) => MilestoneApprovalScreen(
              milestoneId: state.pathParameters['milestoneId']!,
            ),
          ),

          // Tasks
          GoRoute(
            path: '/tasks/create',
            builder: (_, state) {
              final initialProjectId = state.extra as String?;
              return CreateTaskScreen(initialProjectId: initialProjectId);
            },
          ),
          GoRoute(
            path: '/tasks/:taskId',
            builder: (_, state) => TaskDetailScreen(
              taskId: state.pathParameters['taskId']!,
            ),
          ),

          // Deliverables
          GoRoute(
            path: '/deliverables/upload',
            builder: (_, state) => UploadDeliverableScreen(
              projectId: state.uri.queryParameters['projectId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/deliverables/preview',
            builder: (_, state) => FilePreviewScreen(
              fileUrl: state.uri.queryParameters['url'] ?? '',
              fileName: state.uri.queryParameters['name'] ?? 'File',
            ),
          ),

          // Chat
          GoRoute(
            path: '/chat',
            builder: (_, __) => const InboxListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const NewConversationScreen(),
              ),
              GoRoute(
                path: ':conversationId',
                builder: (_, state) => ChatScreen(
                  conversationId: state.pathParameters['conversationId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'video-call',
                    builder: (_, state) => VideoCallScreen(
                      conversationId: state.pathParameters['conversationId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Invoices / Payments
          GoRoute(
            path: '/invoices',
            builder: (_, __) => const InvoicesListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateInvoiceScreen(),
              ),
              GoRoute(
                path: ':invoiceId',
                builder: (_, state) => InvoiceDetailScreen(
                  invoiceId: state.pathParameters['invoiceId']!,
                ),
              ),
            ],
          ),

          // Wallet
          GoRoute(
            path: '/wallet',
            builder: (_, __) => const WalletDashboardScreen(),
          ),

          // Notifications
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),

          // Client Portal
          GoRoute(
            path: '/client-portal',
            builder: (_, __) => const ClientPortalHomeScreen(),
          ),

          // Time Tracking
          GoRoute(
            path: '/time-tracker/:taskId',
            builder: (_, state) => TimeTrackerScreen(taskId: state.pathParameters['taskId']!),
          ),
          GoRoute(
            path: '/time-logs/:projectId',
            builder: (_, state) => TimeLogsScreen(projectId: state.pathParameters['projectId']!),
          ),

          // Proposals
          GoRoute(
            path: '/proposals',
            builder: (_, __) => const ProposalsListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, state) => CreateProposalScreen(
                  projectId: state.uri.queryParameters['projectId'],
                ),
              ),
              GoRoute(
                path: ':proposalId',
                builder: (_, state) => ProposalDetailScreen(proposalId: state.pathParameters['proposalId']!),
              ),
            ],
          ),

          // Contracts
          GoRoute(
            path: '/contracts',
            builder: (_, __) => const ContractsListScreen(),
            routes: [
              GoRoute(
                path: ':contractId',
                builder: (_, state) => ContractDetailScreen(contractId: state.pathParameters['contractId']!),
              ),
            ],
          ),

          // Expenses
          GoRoute(
            path: '/expenses',
            builder: (_, __) => const ExpensesListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddExpenseScreen(),
              ),
            ],
          ),

          // Feedback
          GoRoute(
            path: '/feedback/:projectId',
            builder: (_, state) => FeedbackScreen(projectId: state.pathParameters['projectId']!),
          ),

          // Calendar & Activity
          GoRoute(
            path: '/calendar',
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/activity-log',
            builder: (_, __) => const ActivityLogScreen(),
          ),

          // Edit Profile
          GoRoute(
            path: '/profile/edit',
            builder: (_, __) => const EditProfileScreen(),
          ),
          // Billing, Support, Team
          GoRoute(
            path: '/profile/billing',
            builder: (_, __) => const BillingScreen(),
          ),
          GoRoute(
            path: '/profile/support',
            builder: (_, __) => const SupportScreen(),
            routes: [
              GoRoute(
                path: 'chat',
                builder: (_, __) => const SupportChatScreen(),
              ),
              GoRoute(
                path: 'faqs',
                builder: (_, __) => const FaqScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile/team',
            builder: (_, __) => const TeamScreen(),
          ),
          // Profile Screen
          GoRoute(
            path: '/profile',
            builder: (_, state) {
              final role = ref.read(currentUserRoleProvider);
              final defaultUid = role == UserRole.client ? 'seed_client_001' : 'seed_freelancer_001';
              final uid = state.uri.queryParameters['uid'] ?? defaultUid;
              return ProfileScreen(uid: uid);
            },
          ),
          GoRoute(
            path: '/profile/:uid',
            builder: (_, state) => ProfileScreen(
              uid: state.pathParameters['uid']!,
            ),
          ),
          // Settings Screen
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'change-password',
                builder: (_, __) => const ChangePasswordScreen(),
              ),
              GoRoute(
                path: '2fa',
                builder: (_, __) => const TwoFactorAuthScreen(),
              ),
              GoRoute(
                path: 'legal',
                builder: (_, state) {
                  final title = state.uri.queryParameters['title'] ?? 'Legal Document';
                  return LegalDocumentScreen(title: title);
                },
              ),
            ],
          ),
          // Analytics Screen
          GoRoute(
            path: '/analytics',
            builder: (_, __) => const AnalyticsScreen(),
          ),
          // Search Screen
          GoRoute(
            path: '/search',
            builder: (_, __) => const SearchScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
