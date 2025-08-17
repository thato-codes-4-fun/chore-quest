# ChoreQuest - Family Task Management System

A modern Flutter mobile application that helps families manage chores and rewards through a gamified task system. Parents can assign chores to their children, who earn points upon completion and approval, which they can then redeem for rewards.

## 🎯 Features

### 👨‍👩‍👧‍👦 **Family Management**
- **Parent & Child Roles**: Distinct user roles with different permissions and interfaces
- **Family Overview**: Dashboard showing family members, chore progress, and recent activity
- **User Profiles**: Individual profiles with balance tracking and statistics

###  **Chore Management**
- **Create Chores**: Parents can create detailed chores with descriptions and point values
- **Assign Chores**: Assign specific chores to family members
- **Photo Proof**: Kids must submit photos as proof of completion
- **Notes System**: Optional notes for additional context
- **Status Tracking**: Real-time status updates (assigned → completed → approved/rejected)

### ✅ **Approval System**
- **Parent Review**: Parents review completed chores with proof images and notes
- **Approve/Reject**: Parents can approve or reject submissions with feedback
- **Point Awarding**: Points are only awarded upon parent approval
- **Resubmission**: Kids can resubmit rejected chores with improvements

###  **Reward System**
- **Create Rewards**: Parents can create rewards with point costs
- **Redeem Rewards**: Kids can redeem points for rewards
- **Balance Tracking**: Real-time point balance updates
- **Transaction History**: Complete history of all point transactions

###  **Modern UI/UX**
- **Animated Interfaces**: Smooth animations for login, signup, and interactions
- **Responsive Design**: Works seamlessly across different screen sizes
- **Haptic Feedback**: Tactile feedback for better user experience
- **Dark/Light Theme Support**: Consistent theming throughout the app

## ️ Architecture

### **Frontend (Flutter)**
- **State Management**: Provider pattern for reactive state management
- **Local Storage**: Hive database for offline caching
- **UI Components**: Reusable widgets with consistent design system
- **Navigation**: Intuitive navigation between screens

### **Backend (Supabase)**
- **Authentication**: Secure user authentication and session management
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Real-time**: Live updates across devices
- **Storage**: File storage for proof images (planned)

### **Data Models**
- **Users**: Family members with roles, balances, and profiles
- **Chores**: Task definitions with status tracking
- **Rewards**: Reward definitions with point costs
- **Transactions**: Point transaction history

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- iOS Simulator / Android Emulator / Physical Device
- Supabase Account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/thato-codes-4-fun/chore-quest.git
   cd chore-quest
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new Supabase project
   - Run the database setup scripts (see Database Setup section)
   - Update `lib/constants/supabase_constants.dart` with your project credentials

4. **Run the application**
   ```bash
   flutter run
   ```

## 🗄️ Database Setup

### Required Tables

Run these SQL scripts in your Supabase SQL editor:

#### 1. Users Table
```sql
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('parent', 'kid')),
    parent_id UUID REFERENCES public.users(id),
    balance DECIMAL(10,2) DEFAULT 0.0,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. Chores Table
```sql
CREATE TABLE public.chores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    value DECIMAL(10,2) NOT NULL,
    assigned_to UUID REFERENCES public.users(id),
    assigned_by UUID REFERENCES public.users(id),
    status TEXT NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned', 'completed', 'approved', 'rejected')),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    proof_image_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 3. Rewards Table
```sql
CREATE TABLE public.rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    cost DECIMAL(10,2) NOT NULL,
    reward_type TEXT NOT NULL DEFAULT 'physical' CHECK (reward_type IN ('physical', 'experience', 'privilege')),
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 4. Transactions Table
```sql
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id),
    type TEXT NOT NULL CHECK (type IN ('chore_completed', 'reward_redeemed')),
    amount DECIMAL(10,2) NOT NULL,
    balance_after DECIMAL(10,2) NOT NULL,
    related_id UUID,
    related_type TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Row Level Security (RLS) Policies

Enable RLS and add these policies:

```sql
-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert their own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Parents can view family members" ON public.users FOR SELECT USING (
    auth.uid() = id OR 
    parent_id = auth.uid() OR 
    id IN (SELECT parent_id FROM public.users WHERE id = auth.uid())
);

-- Chores policies
CREATE POLICY "Users can view assigned chores" ON public.chores FOR SELECT USING (
    assigned_to = auth.uid() OR 
    assigned_by = auth.uid() OR
    assigned_by IN (SELECT id FROM public.users WHERE parent_id = auth.uid())
);
CREATE POLICY "Parents can create chores" ON public.chores FOR INSERT WITH CHECK (assigned_by = auth.uid());
CREATE POLICY "Users can update their chores" ON public.chores FOR UPDATE USING (
    assigned_to = auth.uid() OR 
    assigned_by = auth.uid()
);

-- Rewards policies
CREATE POLICY "Users can view active rewards" ON public.rewards FOR SELECT USING (is_active = true);
CREATE POLICY "Parents can create rewards" ON public.rewards FOR INSERT WITH CHECK (created_by = auth.uid());
CREATE POLICY "Parents can update their rewards" ON public.rewards FOR UPDATE USING (created_by = auth.uid());

-- Transactions policies
CREATE POLICY "Users can view their transactions" ON public.transactions FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "System can create transactions" ON public.transactions FOR INSERT WITH CHECK (true);
```

## 📱 Usage Guide

### For Parents

#### 1. **Getting Started**
- Sign up with a "parent" role
- Add family members (kids) to your account
- Set up initial rewards for your kids

#### 2. **Creating Chores**
- Navigate to "Chore Management"
- Tap "Add Chore"
- Fill in chore details (name, description, points, assignee)
- Save the chore

#### 3. **Reviewing Completed Chores**
- Check the "Pending Review" section
- Tap on completed chores to review
- View proof images and notes
- Approve or reject with feedback

#### 4. **Managing Rewards**
- Create rewards with point costs
- Set reward types (physical, experience, privilege)
- Activate/deactivate rewards as needed

### For Kids

#### 1. **Getting Started**
- Sign up with a "kid" role
- Select your parent from the dropdown
- Start viewing assigned chores

#### 2. **Completing Chores**
- View assigned chores in your dashboard
- Tap "Complete" on a chore
- Take a photo as proof
- Add optional notes
- Submit for parent review

#### 3. **Resubmitting Rejected Chores**
- View rejected chores
- Tap "Resubmit"
- Take a better photo
- Add improved notes
- Submit again

#### 4. **Redeeming Rewards**
- Check your point balance
- Browse available rewards
- Tap "Redeem" on desired rewards
- Confirm redemption

##  Design System

### Colors
- **Primary**: `#6366F1` (Indigo)
- **Secondary**: `#8B5CF6` (Purple)
- **Success**: `#10B981` (Emerald)
- **Warning**: `#F59E0B` (Amber)
- **Error**: `#EF4444` (Red)

### Typography
- **Headings**: Bold, large text for titles
- **Body**: Regular weight for content
- **Captions**: Smaller text for metadata

### Spacing
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px

##  Configuration

### Environment Variables
Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### App Constants
Update `lib/constants/app_constants.dart` to customize:
- App colors
- Text styles
- Spacing values
- Border radius values

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: UI framework
- `supabase_flutter`: Backend services
- `provider`: State management
- `hive`: Local storage
- `image_picker`: Photo capture
- `uuid`: Unique ID generation

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support, email support@chorequest.com or create an issue in the GitHub repository.

## 🗺️ Roadmap

### Phase 2 Features
- [ ] Real-time notifications
- [ ] Push notifications
- [ ] Image upload to Supabase Storage
- [ ] Chore templates
- [ ] Recurring chores
- [ ] Chore streaks and achievements
- [ ] Family chat
- [ ] Chore history analytics

### Phase 3 Features
- [ ] Multiple families support
- [ ] Advanced reporting
- [ ] Integration with smart home devices
- [ ] Voice commands
- [ ] AI-powered chore suggestions

---

**Built with ❤️ for families everywhere**

