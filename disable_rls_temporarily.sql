-- Temporarily disable RLS for user creation
-- Run this in your Supabase SQL Editor

-- Disable RLS temporarily
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- Test if you can insert a user now
-- (You can remove this after testing)

-- Re-enable RLS after testing (uncomment when ready)
-- ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
