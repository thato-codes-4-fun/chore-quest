# ChoreQuest Blueprint

## Project Overview

**Project Name:** ChoreQuest (Working Name)

**Problem:** South African parents struggle to manage kids' chores and allowance using traditional methods (paper charts, verbal reminders, WhatsApp), leading to forgotten chores, conflicts, and a lack of structured reward systems.

**Solution:** A simple mobile application designed for South African families to effectively track chores, foster responsibility in children, and implement a fair reward system.

## Features

*   **Parent Features:**
    *   Assign chores to specific children.
    *   Set a value for each chore (e.g., Rands, stars, points).
    *   Approve completed chores (with optional photo proof review).
    *   Track children's balance/progress.
    *   Set up and manage rewards (short-term and long-term goals).
*   **Kid Features:**
    *   View assigned chores.
    *   Mark chores as completed.
    *   Option to upload photo proof of completion.
    *   View current balance/progress.
    *   Track progress towards chosen rewards.
*   **Core Features:**
    *   Chore tracking and management.
    *   Value assignment for chores (Rands, stars, points).
    *   Approval workflow for completed chores.
    *   Balance/point system.
    *   Reward tracking (short-term and long-term).
    *   User accounts (Parent and Kid roles).
    *   Data persistence.
*   **Gamification:**
    *   Streaks for completing chores consistently.
    *   Star or point system for motivation.
    *   "Quests" (potentially groups of chores or challenges).

## Design

*   **User Interface:** Clean and intuitive design, appealing to both parents and children. Use of Material Design principles.
*   **Theme:** Family-friendly and engaging visuals. Consider South African cultural elements subtly.
*   **User Experience:** Simple workflows for assigning, completing, and approving chores. Clear visual feedback for progress and rewards.

## Architecture

*   **Mobile Framework:** Flutter
*   **Backend:** supabase (Authentication, storage for data storage, Storage for photo proofs).
*   **State Management:** provider
*   **Navigation:** go_router
*   **Data Model:**
    *   Users (Parents, Kids)
    *   Chores (Name, Value, Assignee, Status, Proof - optional)
    *   Rewards (Name, Cost/Target, Type - short/long term)
    *   Transactions/History (Chore completion, Reward redemption)
    *   User Balances/Points
*   **Potential Future Additions:**
    *   Recurring chores.
    *   Customizable chore categories.
    *   Notifications.
    *   Family-wide challenges.
    *   Reporting/Analytics for parents.