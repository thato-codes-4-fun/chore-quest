-- Fix RLS Policies for ChoreQuest
-- Run this in your Supabase SQL Editor

-- First, let's see what policies exist
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'users';

-- Drop the problematic insert policy
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;

-- Create a new, simpler insert policy
CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Also drop and recreate the update policy to be safe
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Drop and recreate the select policy
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;

CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Drop and recreate the family view policy
DROP POLICY IF EXISTS "Parents can view their kids' profiles" ON public.users;

CREATE POLICY "Parents can view their kids' profiles" ON public.users
    FOR SELECT USING (
        auth.uid() = parent_id OR 
        auth.uid() = id OR 
        parent_id = (SELECT parent_id FROM public.users WHERE id = auth.uid())
    );

-- Verify the policies are created correctly
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'users';
