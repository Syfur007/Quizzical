f#!/bin/bash

# Firebase Configuration Setup Script for Quizzical App
# This script helps you configure Firebase for your Flutter app

echo "================================================"
echo "Firebase Configuration Setup for Quizzical App"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if FlutterFire CLI is installed
echo "Checking for FlutterFire CLI..."
if ! command -v flutterfire &> /dev/null; then
    echo -e "${YELLOW}FlutterFire CLI not found. Installing...${NC}"
    dart pub global activate flutterfire_cli

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ FlutterFire CLI installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install FlutterFire CLI${NC}"
        echo "Please install it manually: dart pub global activate flutterfire_cli"
        exit 1
    fi
else
    echo -e "${GREEN}✓ FlutterFire CLI is installed${NC}"
fi

echo ""

# Check if Firebase CLI is installed
echo "Checking for Firebase CLI..."
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}Firebase CLI not found.${NC}"
    echo "Please install it with: npm install -g firebase-tools"
    echo "Then run: firebase login"
    echo ""
    read -p "Press Enter to continue without Firebase CLI, or Ctrl+C to exit and install it first..."
else
    echo -e "${GREEN}✓ Firebase CLI is installed${NC}"

    # Check if logged in
    echo "Checking Firebase login status..."
    firebase projects:list &> /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Logged in to Firebase${NC}"
    else
        echo -e "${YELLOW}Not logged in to Firebase. Logging in...${NC}"
        firebase login
    fi
fi

echo ""
echo "================================================"
echo "Running FlutterFire Configure"
echo "================================================"
echo ""
echo "This will:"
echo "  1. Show your Firebase projects"
echo "  2. Let you select or create a project"
echo "  3. Generate firebase_options.dart with correct values"
echo "  4. Set up Firebase for Android, iOS, and Web"
echo ""
read -p "Press Enter to continue..."

# Run flutterfire configure
flutterfire configure

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}✓ Firebase Configuration Complete!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Enable Authentication in Firebase Console:"
    echo "   - Go to: https://console.firebase.google.com/"
    echo "   - Select your project"
    echo "   - Go to Authentication → Sign-in method"
    echo "   - Enable 'Email/Password'"
    echo ""
    echo "2. Create Firestore Database:"
    echo "   - Go to Firestore Database"
    echo "   - Click 'Create Database'"
    echo "   - Choose 'Start in test mode'"
    echo ""
    echo "3. Clean and rebuild your app:"
    echo "   flutter clean"
    echo "   flutter pub get"
    echo "   flutter run"
    echo ""
    echo -e "${GREEN}Registration should now work! 🎉${NC}"
else
    echo ""
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}✗ Configuration Failed${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
    echo "Please try manual configuration:"
    echo "1. Go to: https://console.firebase.google.com/"
    echo "2. Select or create your project"
    echo "3. Download google-services.json for Android"
    echo "4. Place it in: android/app/google-services.json"
    echo "5. See FIREBASE_SETUP_URGENT.md for detailed instructions"
fi

echo ""

