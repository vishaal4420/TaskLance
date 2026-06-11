class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.tasklance.app/v1';

  // Auth
  static const String authProfile = '/auth/profile';
  static const String authSessions = '/auth/sessions';

  // Users
  static String userPublic(String uid) => '/users/$uid/public';
  static String userUpdate(String uid) => '/users/$uid';
  static const String users = '/users';

  // Projects
  static const String projects = '/projects';
  static String projectById(String id) => '/projects/$id';
  static String projectMembers(String id) => '/projects/$id/members';
  static String projectMember(String projectId, String uid) =>
      '/projects/$projectId/members/$uid';
  static String projectMilestones(String id) => '/projects/$id/milestones';

  // Milestones
  static const String milestones = '/milestones';
  static String milestoneById(String id) => '/milestones/$id';
  static String milestoneStatus(String id) => '/milestones/$id/status';

  // Tasks
  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';
  static String taskStatus(String id) => '/tasks/$id/status';

  // Invoices
  static const String invoices = '/invoices';
  static String invoiceById(String id) => '/invoices/$id';

  // Payments
  static const String payments = '/payments';

  // Analytics
  static const String analyticsEarnings = '/analytics/earnings';
  static String analyticsProject(String id) => '/analytics/projects/$id';
  static const String analyticsSpend = '/analytics/spend';
  static const String analyticsProductivity = '/analytics/productivity';

  // Time logs
  static const String timeLogs = '/time-logs';

  // Search
  static const String search = '/search';

  // Billing
  static const String billingPlans = '/billing/plans';
  static const String billingCheckout = '/billing/create-checkout';

  // Invites
  static const String invites = '/invites';

  // Support
  static const String supportTickets = '/support/tickets';

  // Notifications
  static const String notificationsSubscribe = '/notifications/subscribe';

  // Deliverables
  static const String deliverables = '/deliverables';
}
