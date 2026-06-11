import '../models/user.dart';
import '../models/project.dart';
import '../models/milestone.dart';
import '../models/task.dart';
import '../models/invoice.dart';
import '../models/message.dart';
import '../models/payment.dart';
import '../models/notification_model.dart';

class SeedData {
  SeedData._();

  // ─── Users ───────────────────────────────────────────────────────────────
  static final List<UserModel> users = [
    UserModel(
      uid: 'seed_freelancer_001',
      name: 'Alex Rivera',
      email: 'alex.rivera@example.com',
      avatarUrl: null,
      bio:
          'Full-stack developer specializing in Flutter and Node.js with 5+ years of experience building scalable web and mobile apps.',
      tagline: 'Flutter & Node.js Developer',
      role: UserRole.freelancer,
      skills: ['Flutter', 'Dart', 'Node.js', 'Firebase', 'PostgreSQL', 'REST APIs'],
      hourlyRate: 85,
      githubUrl: 'https://github.com/alexrivera',
      linkedinUrl: 'https://linkedin.com/in/alexrivera',
      portfolioUrl: 'https://alexrivera.dev',
      rating: 4.8,
      reviewCount: 24,
      projectsCompleted: 18,
      totalEarned: 42500,
      onTimePercent: 94,
      emailVerified: true,
      createdAt: DateTime(2024, 1, 15),
    ),
    UserModel(
      uid: 'seed_client_001',
      name: 'Sarah Chen',
      email: 'sarah.chen@techcorp.com',
      avatarUrl: null,
      bio:
          'Product manager at TechCorp Inc. building the next generation of enterprise tools.',
      tagline: 'Product Manager @ TechCorp',
      role: UserRole.client,
      companyName: 'TechCorp Inc.',
      industry: 'Technology',
      rating: 4.9,
      reviewCount: 12,
      projectsCompleted: 7,
      totalEarned: 0,
      onTimePercent: 0,
      emailVerified: true,
      createdAt: DateTime(2024, 2, 10),
    ),
    UserModel(
      uid: 'seed_client_002',
      name: 'Marcus Johnson',
      email: 'marcus@startupventures.io',
      avatarUrl: null,
      bio:
          'Founder and CEO of StartupVentures, building tools for early-stage founders.',
      tagline: 'Founder @ StartupVentures',
      role: UserRole.client,
      companyName: 'StartupVentures',
      industry: 'Venture Capital',
      rating: 4.6,
      reviewCount: 5,
      projectsCompleted: 3,
      totalEarned: 0,
      onTimePercent: 0,
      emailVerified: true,
      createdAt: DateTime(2024, 3, 5),
    ),
  ];

  static UserModel get currentFreelancer => users[0];
  static UserModel get currentClient => users[1];

  // ─── Projects ─────────────────────────────────────────────────────────────
  static final List<ProjectModel> projects = [
    ProjectModel(
      id: 'seed_project_001',
      title: 'TechCorp Mobile App Redesign',
      description:
          'Complete redesign of the TechCorp iOS and Android mobile application, implementing new design system, improved UX flows, and performance optimizations.',
      freelancerUid: 'seed_freelancer_001',
      clientUid: 'seed_client_001',
      clientName: 'Sarah Chen',
      status: ProjectStatus.active,
      pricingType: PricingType.fixedPrice,
      budget: 8500,
      spent: 3200,
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 6, 30),
      completedMilestones: 2,
      totalMilestones: 5,
      teamMemberUids: ['seed_freelancer_001'],
      createdAt: DateTime(2026, 2, 25),
    ),
    ProjectModel(
      id: 'seed_project_002',
      title: 'StartupVentures Dashboard',
      description:
          'Analytics and portfolio management dashboard for tracking startup investments, metrics, and communication with founders.',
      freelancerUid: 'seed_freelancer_001',
      clientUid: 'seed_client_002',
      clientName: 'Marcus Johnson',
      status: ProjectStatus.active,
      pricingType: PricingType.hourly,
      budget: 5000,
      spent: 2100,
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 7, 15),
      completedMilestones: 1,
      totalMilestones: 4,
      teamMemberUids: ['seed_freelancer_001'],
      createdAt: DateTime(2026, 3, 28),
    ),
    ProjectModel(
      id: 'seed_project_003',
      title: 'E-Commerce Platform Integration',
      description:
          'Stripe payment integration, inventory management system, and automated email notifications for the TechCorp e-commerce platform.',
      freelancerUid: 'seed_freelancer_001',
      clientUid: 'seed_client_001',
      clientName: 'Sarah Chen',
      status: ProjectStatus.completed,
      pricingType: PricingType.fixedPrice,
      budget: 3500,
      spent: 3500,
      startDate: DateTime(2025, 11, 1),
      endDate: DateTime(2026, 1, 31),
      completedMilestones: 4,
      totalMilestones: 4,
      teamMemberUids: ['seed_freelancer_001'],
      createdAt: DateTime(2025, 10, 28),
    ),
  ];

  // ─── Milestones ───────────────────────────────────────────────────────────
  static final List<MilestoneModel> milestones = [
    MilestoneModel(
      id: 'seed_ms_001',
      projectId: 'seed_project_001',
      title: 'Discovery & Design System',
      description:
          'User research, competitive analysis, and creation of the new design system including color palette, typography, components, and design tokens.',
      status: MilestoneStatus.approved,
      value: 1500,
      dueDate: DateTime(2026, 3, 31),
      assigneeUid: 'seed_freelancer_001',
      completedTasks: 4,
      totalTasks: 4,
      createdAt: DateTime(2026, 3, 1),
    ),
    MilestoneModel(
      id: 'seed_ms_002',
      projectId: 'seed_project_001',
      title: 'Core Screen Implementation',
      description:
          'Implement all primary app screens: onboarding, dashboard, project list, profile, and settings following the approved design system.',
      status: MilestoneStatus.approved,
      value: 2000,
      dueDate: DateTime(2026, 4, 30),
      assigneeUid: 'seed_freelancer_001',
      completedTasks: 6,
      totalTasks: 6,
      createdAt: DateTime(2026, 3, 1),
    ),
    MilestoneModel(
      id: 'seed_ms_003',
      projectId: 'seed_project_001',
      title: 'Backend API Integration',
      description:
          'Connect all screens to the REST API, implement auth flows, caching strategy, and offline support.',
      status: MilestoneStatus.inProgress,
      value: 2000,
      dueDate: DateTime(2026, 5, 31),
      assigneeUid: 'seed_freelancer_001',
      completedTasks: 3,
      totalTasks: 7,
      createdAt: DateTime(2026, 3, 1),
    ),
    MilestoneModel(
      id: 'seed_ms_004',
      projectId: 'seed_project_001',
      title: 'Testing & QA',
      description:
          'Write unit tests, widget tests, and integration tests. Conduct cross-device testing and fix reported bugs.',
      status: MilestoneStatus.upcoming,
      value: 1500,
      dueDate: DateTime(2026, 6, 15),
      assigneeUid: 'seed_freelancer_001',
      completedTasks: 0,
      totalTasks: 5,
      createdAt: DateTime(2026, 3, 1),
    ),
    MilestoneModel(
      id: 'seed_ms_005',
      projectId: 'seed_project_001',
      title: 'Deployment & Launch',
      description:
          'App store submissions, CI/CD pipeline setup, monitoring integration, and post-launch support.',
      status: MilestoneStatus.upcoming,
      value: 1500,
      dueDate: DateTime(2026, 6, 30),
      assigneeUid: 'seed_freelancer_001',
      completedTasks: 0,
      totalTasks: 4,
      createdAt: DateTime(2026, 3, 1),
    ),
    MilestoneModel(
      id: 'seed_ms_006',
      projectId: 'seed_project_002',
      title: 'Data Architecture & API Design',
      description:
          'Design the database schema, API endpoints, and data models for the analytics dashboard.',
      status: MilestoneStatus.approved,
      value: 1200,
      dueDate: DateTime(2026, 4, 20),
      assigneeUid: 'seed_freelancer_001',
      completedTasks: 3,
      totalTasks: 3,
      createdAt: DateTime(2026, 3, 28),
    ),
    MilestoneModel(
      id: 'seed_ms_007',
      projectId: 'seed_project_002',
      title: 'Dashboard UI Implementation',
      description:
          'Build the main dashboard with charts, KPI cards, portfolio table, and filtering capabilities.',
      status: MilestoneStatus.inProgress,
      value: 1400,
      dueDate: DateTime(2026, 5, 20),
      assigneeUid: 'seed_freelancer_001',
      completedTasks: 2,
      totalTasks: 5,
      createdAt: DateTime(2026, 3, 28),
    ),
  ];

  // ─── Tasks ────────────────────────────────────────────────────────────────
  static final List<TaskModel> tasks = [
    TaskModel(
      id: 'seed_task_001',
      projectId: 'seed_project_001',
      milestoneId: 'seed_ms_003',
      title: 'Implement Firebase Auth with Google Sign-In',
      description:
          'Set up Firebase Authentication with Google OAuth, Apple Sign-In, and email/password flows. Include refresh token handling and session persistence.',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 10),
      createdAt: DateTime(2026, 5, 1),
    ),
    TaskModel(
      id: 'seed_task_002',
      projectId: 'seed_project_001',
      milestoneId: 'seed_ms_003',
      title: 'Build project listing API integration',
      description:
          'Connect the projects screen to the REST API. Implement pagination, pull-to-refresh, and error handling with retry logic.',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 15),
      createdAt: DateTime(2026, 5, 1),
    ),
    TaskModel(
      id: 'seed_task_003',
      projectId: 'seed_project_001',
      milestoneId: 'seed_ms_003',
      title: 'Implement offline caching with Hive',
      description:
          'Add local data persistence using Hive. Cache project data, user profile, and settings. Handle sync conflicts gracefully.',
      status: TaskStatus.done,
      priority: TaskPriority.medium,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 18),
      createdAt: DateTime(2026, 5, 1),
    ),
    TaskModel(
      id: 'seed_task_004',
      projectId: 'seed_project_001',
      milestoneId: 'seed_ms_003',
      title: 'Milestone status update flow',
      description:
          'Build the UI and API integration for updating milestone status. Include confirmation dialogs and status history tracking.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 25),
      createdAt: DateTime(2026, 5, 5),
    ),
    TaskModel(
      id: 'seed_task_005',
      projectId: 'seed_project_001',
      milestoneId: 'seed_ms_003',
      title: 'File upload and preview',
      description:
          'Implement file picker, Firebase Storage upload, progress indicator, and file preview for images and PDFs.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 28),
      createdAt: DateTime(2026, 5, 5),
    ),
    TaskModel(
      id: 'seed_task_006',
      projectId: 'seed_project_001',
      milestoneId: 'seed_ms_003',
      title: 'Push notifications integration',
      description:
          'Integrate Firebase Cloud Messaging for push notifications. Handle foreground, background, and terminated app states.',
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 31),
      createdAt: DateTime(2026, 5, 5),
    ),
    TaskModel(
      id: 'seed_task_007',
      projectId: 'seed_project_001',
      milestoneId: 'seed_ms_003',
      title: 'Analytics event tracking',
      description:
          'Add Firebase Analytics events for key user actions: sign-in, project create, milestone update, invoice sent.',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 31),
      createdAt: DateTime(2026, 5, 5),
    ),
    TaskModel(
      id: 'seed_task_008',
      projectId: 'seed_project_002',
      milestoneId: 'seed_ms_007',
      title: 'Build earnings chart component',
      description:
          'Create an interactive line/bar chart showing monthly earnings. Support date range filtering and comparison periods.',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 10),
      createdAt: DateTime(2026, 4, 25),
    ),
    TaskModel(
      id: 'seed_task_009',
      projectId: 'seed_project_002',
      milestoneId: 'seed_ms_007',
      title: 'Portfolio KPI cards',
      description:
          'Design and implement KPI summary cards showing total invested, active companies, exits, and IRR.',
      status: TaskStatus.done,
      priority: TaskPriority.high,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 12),
      createdAt: DateTime(2026, 4, 25),
    ),
    TaskModel(
      id: 'seed_task_010',
      projectId: 'seed_project_002',
      milestoneId: 'seed_ms_007',
      title: 'Investment table with sorting & filtering',
      description:
          'Build a data table for portfolio companies with sortable columns, search, and category filters.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      assigneeUid: 'seed_freelancer_001',
      assigneeName: 'Alex Rivera',
      dueDate: DateTime(2026, 5, 20),
      createdAt: DateTime(2026, 4, 25),
    ),
  ];

  // ─── Invoices ─────────────────────────────────────────────────────────────
  static final List<InvoiceModel> invoices = [
    InvoiceModel(
      id: 'seed_inv_001',
      invoiceNumber: 'INV-2026-001',
      projectId: 'seed_project_001',
      projectName: 'TechCorp Mobile App Redesign',
      freelancerUid: 'seed_freelancer_001',
      clientUid: 'seed_client_001',
      clientName: 'Sarah Chen',
      lineItems: [
        const InvoiceLineItem(
          description: 'Discovery & Design System',
          quantity: 1,
          unitPrice: 1500,
        ),
      ],
      taxPercent: 0,
      discountPercent: 0,
      notes: 'Payment for Milestone 1: Discovery & Design System. Thank you for the opportunity!',
      dueDate: DateTime(2026, 4, 10),
      createdAt: DateTime(2026, 4, 1),
      status: InvoiceStatus.paid,
    ),
    InvoiceModel(
      id: 'seed_inv_002',
      invoiceNumber: 'INV-2026-002',
      projectId: 'seed_project_001',
      projectName: 'TechCorp Mobile App Redesign',
      freelancerUid: 'seed_freelancer_001',
      clientUid: 'seed_client_001',
      clientName: 'Sarah Chen',
      lineItems: [
        const InvoiceLineItem(
          description: 'Core Screen Implementation',
          quantity: 1,
          unitPrice: 2000,
        ),
      ],
      taxPercent: 0,
      discountPercent: 0,
      notes: 'Payment for Milestone 2: Core Screen Implementation.',
      dueDate: DateTime(2026, 5, 10),
      createdAt: DateTime(2026, 5, 1),
      status: InvoiceStatus.paid,
    ),
    InvoiceModel(
      id: 'seed_inv_003',
      invoiceNumber: 'INV-2026-003',
      projectId: 'seed_project_002',
      projectName: 'StartupVentures Dashboard',
      freelancerUid: 'seed_freelancer_001',
      clientUid: 'seed_client_002',
      clientName: 'Marcus Johnson',
      lineItems: [
        const InvoiceLineItem(
          description: 'Data Architecture & API Design',
          quantity: 1,
          unitPrice: 1200,
        ),
        const InvoiceLineItem(
          description: 'Project management & communication',
          quantity: 4,
          unitPrice: 85,
        ),
      ],
      taxPercent: 10,
      discountPercent: 0,
      notes: 'Invoice for completed milestone and additional hours.',
      dueDate: DateTime(2026, 5, 20),
      createdAt: DateTime(2026, 5, 5),
      status: InvoiceStatus.sent,
    ),
    InvoiceModel(
      id: 'seed_inv_004',
      invoiceNumber: 'INV-2026-004',
      projectId: 'seed_project_003',
      projectName: 'E-Commerce Platform Integration',
      freelancerUid: 'seed_freelancer_001',
      clientUid: 'seed_client_001',
      clientName: 'Sarah Chen',
      lineItems: [
        const InvoiceLineItem(
          description: 'Stripe payment integration',
          quantity: 1,
          unitPrice: 1200,
        ),
        const InvoiceLineItem(
          description: 'Inventory management system',
          quantity: 1,
          unitPrice: 1400,
        ),
        const InvoiceLineItem(
          description: 'Automated email notifications',
          quantity: 1,
          unitPrice: 900,
        ),
      ],
      taxPercent: 0,
      discountPercent: 5,
      notes: 'Final invoice for completed project. 5% loyalty discount applied.',
      dueDate: DateTime(2026, 2, 15),
      createdAt: DateTime(2026, 2, 1),
      status: InvoiceStatus.paid,
    ),
  ];

  // ─── Messages / Conversations ─────────────────────────────────────────────
  static final List<ConversationModel> conversations = [
    ConversationModel(
      id: 'seed_conv_001',
      participantUids: ['seed_freelancer_001', 'seed_client_001'],
      participantNames: ['Alex Rivera', 'Sarah Chen'],
      projectId: 'seed_project_001',
      projectName: 'TechCorp Mobile App Redesign',
      lastMessage: 'The API integration is going well, should be done by Friday.',
      lastMessageAt: DateTime(2026, 5, 27, 14, 30),
      unreadCounts: {'seed_client_001': 2},
      isGroup: false,
    ),
    ConversationModel(
      id: 'seed_conv_002',
      participantUids: ['seed_freelancer_001', 'seed_client_002'],
      participantNames: ['Alex Rivera', 'Marcus Johnson'],
      projectId: 'seed_project_002',
      projectName: 'StartupVentures Dashboard',
      lastMessage: 'Can we schedule a call to review the chart designs?',
      lastMessageAt: DateTime(2026, 5, 26, 10, 15),
      unreadCounts: {'seed_freelancer_001': 1},
      isGroup: false,
    ),
  ];

  static final List<MessageModel> messages = [
    MessageModel(
      id: 'seed_msg_001',
      conversationId: 'seed_conv_001',
      senderUid: 'seed_client_001',
      senderName: 'Sarah Chen',
      content: 'Hi Alex! How is the backend API integration coming along?',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime(2026, 5, 27, 9, 0),
    ),
    MessageModel(
      id: 'seed_msg_002',
      conversationId: 'seed_conv_001',
      senderUid: 'seed_freelancer_001',
      senderName: 'Alex Rivera',
      content:
          'Going great! Finished auth and project listing. Working on the milestone update flow now.',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime(2026, 5, 27, 9, 45),
    ),
    MessageModel(
      id: 'seed_msg_003',
      conversationId: 'seed_conv_001',
      senderUid: 'seed_client_001',
      senderName: 'Sarah Chen',
      content: 'Great progress! Can you share a quick demo video when ready?',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime(2026, 5, 27, 10, 0),
    ),
    MessageModel(
      id: 'seed_msg_004',
      conversationId: 'seed_conv_001',
      senderUid: 'seed_freelancer_001',
      senderName: 'Alex Rivera',
      content: 'The API integration is going well, should be done by Friday.',
      type: MessageType.text,
      isRead: false,
      createdAt: DateTime(2026, 5, 27, 14, 30),
    ),
    MessageModel(
      id: 'seed_msg_005',
      conversationId: 'seed_conv_002',
      senderUid: 'seed_freelancer_001',
      senderName: 'Alex Rivera',
      content: 'Marcus, the KPI cards are implemented. Working on the data table now.',
      type: MessageType.text,
      isRead: true,
      createdAt: DateTime(2026, 5, 26, 9, 0),
    ),
    MessageModel(
      id: 'seed_msg_006',
      conversationId: 'seed_conv_002',
      senderUid: 'seed_client_002',
      senderName: 'Marcus Johnson',
      content: 'Can we schedule a call to review the chart designs?',
      type: MessageType.text,
      isRead: false,
      createdAt: DateTime(2026, 5, 26, 10, 15),
    ),
  ];

  // ─── Payments ─────────────────────────────────────────────────────────────
  static final List<PaymentModel> payments = [
    PaymentModel(
      id: 'seed_pay_001',
      invoiceId: 'seed_inv_001',
      invoiceNumber: 'INV-2026-001',
      projectId: 'seed_project_001',
      projectName: 'TechCorp Mobile App Redesign',
      payerUid: 'seed_client_001',
      recipientUid: 'seed_freelancer_001',
      amount: 1500,
      status: PaymentStatus.completed,
      method: PaymentMethod.card,
      stripePaymentIntentId: 'pi_seed_001',
      createdAt: DateTime(2026, 4, 5),
    ),
    PaymentModel(
      id: 'seed_pay_002',
      invoiceId: 'seed_inv_002',
      invoiceNumber: 'INV-2026-002',
      projectId: 'seed_project_001',
      projectName: 'TechCorp Mobile App Redesign',
      payerUid: 'seed_client_001',
      recipientUid: 'seed_freelancer_001',
      amount: 2000,
      status: PaymentStatus.completed,
      method: PaymentMethod.card,
      stripePaymentIntentId: 'pi_seed_002',
      createdAt: DateTime(2026, 5, 6),
    ),
    PaymentModel(
      id: 'seed_pay_003',
      invoiceId: 'seed_inv_004',
      invoiceNumber: 'INV-2026-004',
      projectId: 'seed_project_003',
      projectName: 'E-Commerce Platform Integration',
      payerUid: 'seed_client_001',
      recipientUid: 'seed_freelancer_001',
      amount: 3325,
      status: PaymentStatus.completed,
      method: PaymentMethod.bankTransfer,
      createdAt: DateTime(2026, 2, 12),
    ),
  ];

  // ─── Notifications ────────────────────────────────────────────────────────
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'seed_notif_001',
      userId: 'seed_freelancer_001',
      title: 'Milestone Approved!',
      body: 'Sarah Chen approved "Core Screen Implementation" on TechCorp Mobile App Redesign.',
      type: NotificationType.milestoneApproved,
      deepLink: '/milestones/seed_ms_002',
      isRead: false,
      createdAt: DateTime(2026, 5, 27, 11, 0),
    ),
    NotificationModel(
      id: 'seed_notif_002',
      userId: 'seed_freelancer_001',
      title: 'Payment Received',
      body: 'You received \$2,000 for INV-2026-002.',
      type: NotificationType.paymentReceived,
      deepLink: '/invoices/seed_inv_002',
      isRead: false,
      createdAt: DateTime(2026, 5, 26, 16, 30),
    ),
    NotificationModel(
      id: 'seed_notif_003',
      userId: 'seed_freelancer_001',
      title: 'New Message',
      body: 'Marcus Johnson: Can we schedule a call to review the chart designs?',
      type: NotificationType.message,
      deepLink: '/chat/seed_conv_002',
      isRead: true,
      createdAt: DateTime(2026, 5, 26, 10, 15),
    ),
    NotificationModel(
      id: 'seed_notif_004',
      userId: 'seed_freelancer_001',
      title: 'Deadline Approaching',
      body: '"Backend API Integration" is due in 4 days.',
      type: NotificationType.deadline,
      deepLink: '/milestones/seed_ms_003',
      isRead: true,
      createdAt: DateTime(2026, 5, 25, 9, 0),
    ),
    NotificationModel(
      id: 'seed_notif_005',
      userId: 'seed_freelancer_001',
      title: 'Task Assigned',
      body: 'You were assigned "Push notifications integration".',
      type: NotificationType.newAssignment,
      deepLink: '/tasks/seed_task_006',
      isRead: true,
      createdAt: DateTime(2026, 5, 24, 14, 0),
    ),
  ];

  // ─── Analytics helpers ────────────────────────────────────────────────────
  static double get totalEarningsThisMonth {
    final now = DateTime.now();
    return payments
        .where(
          (p) =>
              p.status == PaymentStatus.completed &&
              p.createdAt.month == now.month &&
              p.createdAt.year == now.year,
        )
        .fold(0, (sum, p) => sum + p.amount);
  }

  static double get totalEarningsAllTime {
    return payments
        .where((p) => p.status == PaymentStatus.completed)
        .fold(0, (sum, p) => sum + p.amount);
  }

  static int get activeProjectCount {
    return projects.where((p) => p.status == ProjectStatus.active).length;
  }

  static int get pendingInvoiceCount {
    return invoices
        .where((i) =>
            i.status == InvoiceStatus.sent || i.status == InvoiceStatus.viewed)
        .length;
  }

  static int get unreadNotificationCount {
    return notifications.where((n) => !n.isRead).length;
  }

  /// Returns the monthly earnings for the last [months] months.
  static List<Map<String, dynamic>> earningsChartData({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final month = DateTime(now.year, now.month - (months - 1 - i));
      final total = payments
          .where(
            (p) =>
                p.status == PaymentStatus.completed &&
                p.createdAt.year == month.year &&
                p.createdAt.month == month.month,
          )
          .fold<double>(0, (sum, p) => sum + p.amount);
      return {'month': month, 'amount': total};
    });
  }

  /// Monthly earnings map (label -> amount) for fl_chart BarChart
  static Map<String, double> get monthlyEarnings => {
        'Jan': 1200,
        'Feb': 800,
        'Mar': 2500,
        'Apr': 1700,
        'May': 3200,
        'Jun': 0,
      };

  /// Shortcut for total earnings (all time)
  static double get totalEarned => totalEarningsAllTime;

  /// Fake time logs for productivity screen
  static final timeLogs = [
    {'task': 'Implement Firebase Auth', 'project': 'TechCorp App', 'minutes': 120, 'date': '2026-05-27'},
    {'task': 'Build project listing', 'project': 'TechCorp App', 'minutes': 90, 'date': '2026-05-27'},
    {'task': 'Offline caching with Hive', 'project': 'TechCorp App', 'minutes': 150, 'date': '2026-05-26'},
    {'task': 'Dashboard KPI cards', 'project': 'StartupVentures', 'minutes': 75, 'date': '2026-05-26'},
  ];

  /// Fake deliverables
  static final deliverables = [
    {'id': 'del_001', 'name': 'Design_System_v2.pdf', 'type': 'pdf', 'status': 'approved', 'milestoneId': 'seed_ms_001', 'milestone': 'Discovery & Design', 'projectId': 'seed_project_001', 'date': '2026-03-28'},
    {'id': 'del_002', 'name': 'Homepage_Mockup.png', 'type': 'image', 'status': 'approved', 'milestoneId': 'seed_ms_002', 'milestone': 'Core Screens', 'projectId': 'seed_project_001', 'date': '2026-04-15'},
    {'id': 'del_003', 'name': 'API_Integration_Spec.docx', 'type': 'doc', 'status': 'review', 'milestoneId': 'seed_ms_003', 'milestone': 'Backend API', 'projectId': 'seed_project_001', 'date': '2026-05-10'},
    {'id': 'del_004', 'name': 'App_Prototype_v3.fig', 'type': 'fig', 'status': 'review', 'milestoneId': 'seed_ms_003', 'milestone': 'Backend API', 'projectId': 'seed_project_001', 'date': '2026-05-20'},
    {'id': 'del_005', 'name': 'Test_Report_QA.pdf', 'type': 'pdf', 'status': 'revision', 'milestoneId': 'seed_ms_004', 'milestone': 'QA Testing', 'projectId': 'seed_project_001', 'date': '2026-05-25'},
    {'id': 'del_006', 'name': 'Final_Build_v1.zip', 'type': 'zip', 'status': 'pending', 'milestoneId': 'seed_ms_005', 'milestone': 'Deployment', 'projectId': 'seed_project_001', 'date': '2026-05-27'},
  ];
}
