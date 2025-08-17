-- ChoreQuest Database Setup - Fixed Version
-- Run this in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables if they exist (be careful with this in production!)
DROP TABLE IF EXISTS public.transactions CASCADE;
DROP TABLE IF EXISTS public.rewards CASCADE;
DROP TABLE IF EXISTS public.chores CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('parent', 'kid')),
    parent_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    balance DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    avatar_url TEXT
);

-- Create chores table
CREATE TABLE IF NOT EXISTS public.chores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    value DECIMAL(10,2) NOT NULL,
    assigned_to UUID REFERENCES public.users(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'approved', 'rejected')),
    proof_image_url TEXT,
    due_date TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create rewards table
CREATE TABLE IF NOT EXISTS public.rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    cost DECIMAL(10,2) NOT NULL,
    type TEXT NOT NULL DEFAULT 'short_term' CHECK (type IN ('short_term', 'long_term')),
    created_by UUID REFERENCES public.users(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create transactions table
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('chore_completed', 'reward_redeemed', 'bonus', 'penalty')),
    amount DECIMAL(10,2) NOT NULL,
    balance_after DECIMAL(10,2) NOT NULL,
    related_id UUID, -- Chore ID or Reward ID
    related_type TEXT, -- 'chore' or 'reward'
    description TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_parent_id ON public.users(parent_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_chores_assigned_to ON public.chores(assigned_to);
CREATE INDEX IF NOT EXISTS idx_chores_assigned_by ON public.chores(assigned_by);
CREATE INDEX IF NOT EXISTS idx_chores_status ON public.chores(status);
CREATE INDEX IF NOT EXISTS idx_rewards_created_by ON public.rewards(created_by);
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON public.transactions(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;
DROP POLICY IF EXISTS "Parents can view their kids' profiles" ON public.users;
DROP POLICY IF EXISTS "Allow profile creation during signup" ON public.users;

-- Create RLS policies for users table (FIXED VERSION)
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- SIMPLIFIED INSERT POLICY - This is the key fix
CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Parents can view their kids' profiles" ON public.users
    FOR SELECT USING (
        auth.uid() = parent_id OR 
        auth.uid() = id OR 
        parent_id = (SELECT parent_id FROM public.users WHERE id = auth.uid())
    );

-- Create RLS policies for chores table
CREATE POLICY "Users can view chores they're involved with" ON public.chores
    FOR SELECT USING (
        auth.uid() = assigned_to OR 
        auth.uid() = assigned_by OR
        assigned_by = (SELECT parent_id FROM public.users WHERE id = auth.uid()) OR
        assigned_to = (SELECT id FROM public.users WHERE parent_id = auth.uid())
    );

CREATE POLICY "Parents can create chores for their kids" ON public.chores
    FOR INSERT WITH CHECK (
        auth.uid() = assigned_by AND
        assigned_to IN (SELECT id FROM public.users WHERE parent_id = auth.uid())
    );

CREATE POLICY "Users can update chores they're involved with" ON public.chores
    FOR UPDATE USING (
        auth.uid() = assigned_to OR 
        auth.uid() = assigned_by
    );

-- Create RLS policies for rewards table
CREATE POLICY "Users can view rewards created by their family" ON public.rewards
    FOR SELECT USING (
        auth.uid() = created_by OR
        created_by = (SELECT parent_id FROM public.users WHERE id = auth.uid()) OR
        created_by IN (SELECT id FROM public.users WHERE parent_id = auth.uid())
    );

CREATE POLICY "Parents can create rewards" ON public.rewards
    FOR INSERT WITH CHECK (
        auth.uid() = created_by AND
        (SELECT role FROM public.users WHERE id = auth.uid()) = 'parent'
    );

CREATE POLICY "Parents can update their rewards" ON public.rewards
    FOR UPDATE USING (auth.uid() = created_by);

-- Create RLS policies for transactions table
CREATE POLICY "Users can view their own transactions" ON public.transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "System can insert transactions" ON public.transactions
    FOR INSERT WITH CHECK (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chores_updated_at BEFORE UPDATE ON public.chores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rewards_updated_at BEFORE UPDATE ON public.rewards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to handle user balance updates
CREATE OR REPLACE FUNCTION update_user_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- Update user balance when transaction is inserted
    UPDATE public.users 
    SET balance = balance + NEW.amount,
        updated_at = NOW()
    WHERE id = NEW.user_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to update user balance on transaction insert
CREATE TRIGGER update_user_balance_trigger 
    AFTER INSERT ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION update_user_balance();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;
