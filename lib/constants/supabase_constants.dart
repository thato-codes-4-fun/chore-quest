class SupabaseConstants {
  // TODO: Replace with your actual Supabase URL and anon key
  static const String supabaseUrl = 'https://jzhtablwkuaxgzzqdcsl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp6aHRhYmx3a3VheGd6enFkY3NsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzMDg5NzgsImV4cCI6MjA2Njg4NDk3OH0.hSuypmba74cSzvZ8Z_zAz4qdY21yl_4t1NKVLLWGv7g';

  // Database table names
  static const String usersTable = 'users';
  static const String choresTable = 'chores';
  static const String rewardsTable = 'rewards';
  static const String transactionsTable = 'transactions';

  // Storage bucket names
  static const String proofImagesBucket = 'proof-images';
  static const String avatarsBucket = 'avatars';

  // Row Level Security (RLS) policies
  static const String usersPolicy = 'users_policy';
  static const String choresPolicy = 'chores_policy';
  static const String rewardsPolicy = 'rewards_policy';
  static const String transactionsPolicy = 'transactions_policy';

  // Authentication
  static const String authRedirectUrl = 'io.supabase.chorequest://login-callback/';
  static const String authCallbackUrl = 'io.supabase.chorequest://login-callback/';

  // Real-time subscriptions
  static const String choresChannel = 'chores';
  static const String rewardsChannel = 'rewards';
  static const String transactionsChannel = 'transactions';
}
