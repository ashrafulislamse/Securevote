# SecureVote — Complete Implementation Blueprint

> **Project:** Design and Implementation of a Secure Online Voting System
> **Student:** Islam MD Rakibul | ID: 202305010188
> **Program:** Bachelor of Information Technology — City University Malaysia
> **Brand:** SecureVote
> **Stack:** Next.js · Flutter · Firebase · Groq AI · Blockchain

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [System Architecture](#2-system-architecture)
3. [Tech Stack — Full Detail](#3-tech-stack--full-detail)
4. [Firebase Ecosystem Setup](#4-firebase-ecosystem-setup)
5. [Blockchain Integration](#5-blockchain-integration)
6. [Database Schema — Firestore](#6-database-schema--firestore)
7. [Authentication & Security](#7-authentication--security)
8. [KYC Verification System](#8-kyc-verification-system)
9. [Cryptographic Engine — Merkle Tree](#9-cryptographic-engine--merkle-tree)
10. [Anomaly Detection Engine](#10-anomaly-detection-engine)
11. [Smart Election Assistant — Groq AI](#11-smart-election-assistant--groq-ai)
12. [Admin Web Portal — Implementation](#12-admin-web-portal--implementation)
13. [Voter Mobile App — Implementation](#13-voter-mobile-app--implementation)
14. [Public Verifier Portal](#14-public-verifier-portal)
15. [API Design](#15-api-design)
16. [Development Phase Plan](#16-development-phase-plan)
17. [Folder Structure](#17-folder-structure)
18. [Environment Variables](#18-environment-variables)
19. [Deployment Guide](#19-deployment-guide)
20. [Testing Strategy](#20-testing-strategy)

---

## 1. Project Overview

### What We Are Building

SecureVote is a full-stack digital election management platform consisting of:

| App | Platform | Screens | Purpose |
|-----|----------|---------|---------|
| Admin Web Portal | Next.js 14 | 24 screens | Election management, KYC review, monitoring |
| Voter Mobile App | Flutter | 26 screens | Voter registration, KYC, voting, receipts |
| Public Verifier | Next.js (route) | 4 screens | Anyone can verify a vote receipt |

### Core Capabilities

- Multi-organization election management
- KYC identity verification (ID + live selfie)
- Biometric login with device binding
- End-to-end vote encryption simulation
- Merkle tree cryptographic receipts
- Blockchain anchoring (Polygon testnet)
- Real-time fraud detection (6 rules)
- AI-powered election assistant (Groq API)
- Real-time monitoring via Firebase

---

## 2. System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENTS                               │
│                                                              │
│   ┌──────────────────┐        ┌──────────────────────────┐  │
│   │  Admin Web Portal │        │   Voter Mobile App       │  │
│   │   Next.js 14      │        │   Flutter (iOS/Android)  │  │
│   └────────┬─────────┘        └────────────┬─────────────┘  │
└────────────┼──────────────────────────────┼─────────────────┘
             │                              │
             ▼                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   FIREBASE ECOSYSTEM                         │
│                                                              │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │  Firebase   │  │  Firestore   │  │  Firebase         │  │
│  │    Auth     │  │  Database    │  │  Storage          │  │
│  └─────────────┘  └──────────────┘  └───────────────────┘  │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Firebase Cloud Functions                │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────┐  │    │
│  │  │  Voting  │ │  Crypto  │ │  Groq AI │ │Anomaly│  │    │
│  │  │ Service  │ │  Engine  │ │Assistant │ │Engine │  │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └───────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────┬───────────────────────────────┘
                              │
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
    ┌─────────────┐  ┌──────────────┐  ┌──────────────┐
    │  Groq API   │  │   Polygon    │  │  FCM Push    │
    │  (Groq LLM) │  │  Blockchain  │  │Notifications │
    └─────────────┘  └──────────────┘  └──────────────┘
```

### Data Flow — Vote Submission

```
Voter opens ballot
       │
       ▼
Vote encrypted client-side (AES-256 simulation)
       │
       ▼
Encrypted vote sent to Cloud Function via HTTPS
       │
       ▼
Cloud Function validates:
  ├── Is voter KYC verified?
  ├── Is voter eligible for this election?
  ├── Has voter already voted?
  ├── Is election currently active?
  └── Is device binding valid?
       │
       ▼
Vote stored in Firestore (encrypted)
       │
       ▼
Anomaly engine checks vote event
       │
       ▼
Merkle leaf generated: hash(voterID + timestamp + encryptedVote)
       │
       ▼
Merkle tree updated with new leaf
       │
       ▼
Receipt returned to voter (receiptID + merkleProof + txHash)
       │
       ▼
When election closes → Merkle root anchored to Polygon blockchain
```

---

## 3. Tech Stack — Full Detail

### Frontend — Admin Web Portal

```
Next.js 14          — App Router, Server Components
TypeScript          — Full type safety
Tailwind CSS        — Styling with dark mode
shadcn/ui           — Component library base
Chart.js            — Analytics charts
React Hook Form     — Form management
Zod                 — Schema validation
Firebase SDK v10    — Auth + Firestore + Storage
ethers.js           — Blockchain interaction
```

### Frontend — Voter Mobile App

```
Flutter 3.x         — Cross-platform iOS + Android
Dart                — Language
Firebase Flutter SDK — Auth + Firestore + Storage + FCM
local_auth          — Biometric authentication
camera              — KYC photo capture
qr_flutter          — QR code generation
fl_chart            — Charts
shared_preferences  — Local storage
crypto              — Hashing utilities
```

### Backend — Firebase Cloud Functions

```
Node.js 18          — Runtime
TypeScript          — Full type safety
Firebase Admin SDK  — Firestore + Auth admin access
Groq SDK            — AI assistant calls
ethers.js           — Polygon blockchain anchoring
crypto (built-in)   — SHA-256 hashing for Merkle
```

### Infrastructure

```
Firebase Auth       — Authentication (Email, Google, Biometric link)
Firebase Firestore  — Primary database (real-time NoSQL)
Firebase Storage    — KYC documents, candidate photos
Firebase Functions  — Serverless backend logic
Firebase FCM        — Push notifications
Vercel              — Next.js hosting (free tier)
Polygon Mumbai      — Blockchain testnet for anchoring
Groq API            — LLM for Smart Assistant
```

---

## 4. Firebase Ecosystem Setup

### Step 1 — Create Firebase Project

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
firebase init

# Select:
# ✅ Firestore
# ✅ Functions
# ✅ Storage
# ✅ Hosting (for web)
# ✅ Emulators
```

### Step 2 — Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Organizations — admin only
    match /organizations/{orgId} {
      allow read: if isOrgMember(orgId);
      allow write: if isOrgAdmin(orgId);
    }

    // Elections — public read if published
    match /elections/{electionId} {
      allow read: if resource.data.status == 'published'
                  || isOrgMember(resource.data.orgId);
      allow write: if isOrgAdmin(resource.data.orgId);
    }

    // Votes — voter can write their own, nobody can read individual votes
    match /votes/{voteId} {
      allow create: if request.auth.uid == request.resource.data.voterId
                    && isEligibleVoter(request.resource.data.electionId);
      allow read: if false; // Nobody reads individual votes
    }

    // KYC documents — voter writes, admin reads
    match /kyc/{kycId} {
      allow create: if request.auth.uid == request.resource.data.userId;
      allow read: if isAdmin();
      allow update: if isAdmin();
    }

    // Receipts — only the voter who owns it
    match /receipts/{receiptId} {
      allow read: if request.auth.uid == resource.data.voterId
                  || resource.data.isPublic == true;
      allow write: if false; // Only Cloud Functions write receipts
    }

    // Helper functions
    function isAdmin() {
      return get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.role
             in ['super_admin', 'org_admin'];
    }

    function isOrgAdmin(orgId) {
      return get(/databases/$(database)/documents/orgMembers/$(request.auth.uid + '_' + orgId))
             .data.role in ['super_admin', 'org_admin'];
    }

    function isOrgMember(orgId) {
      return exists(/databases/$(database)/documents/orgMembers/$(request.auth.uid + '_' + orgId));
    }

    function isEligibleVoter(electionId) {
      let voter = get(/databases/$(database)/documents/voters/$(request.auth.uid));
      return voter.data.kycStatus == 'verified';
    }
  }
}
```

### Step 3 — Storage Rules

```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // KYC documents — only owner uploads, admin reads
    match /kyc/{userId}/{fileName} {
      allow write: if request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
      allow read: if request.auth.uid == userId || isAdmin();
    }

    // Candidate photos — admin only writes, public reads
    match /candidates/{electionId}/{fileName} {
      allow write: if isAdmin();
      allow read: if true;
    }

    function isAdmin() {
      return firestore.get(/databases/(default)/documents/admins/$(request.auth.uid))
             .data.role in ['super_admin', 'org_admin'];
    }
  }
}
```

---

## 5. Blockchain Integration

### Overview

We use **Polygon Mumbai Testnet** (free, fast, Ethereum-compatible) to anchor the Merkle root after each election closes. This proves the final vote tally has not been tampered with after the fact.

### What Gets Anchored

```
After election closes:
  merkleRoot = final Merkle root of all votes
  electionId = SecureVote election ID
  timestamp  = Unix timestamp of closing
  voteCount  = total votes cast

This data is written to a smart contract on Polygon.
The transaction hash (txHash) is stored in Firestore
and shown to voters on their receipt.
```

### Smart Contract — Solidity

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SecureVoteAnchor {

    struct ElectionRecord {
        string electionId;
        bytes32 merkleRoot;
        uint256 voteCount;
        uint256 timestamp;
        address anchoredBy;
    }

    mapping(string => ElectionRecord) public elections;
    address public owner;

    event ElectionAnchored(
        string indexed electionId,
        bytes32 merkleRoot,
        uint256 voteCount,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function anchorElection(
        string memory electionId,
        bytes32 merkleRoot,
        uint256 voteCount
    ) external onlyOwner {
        require(
            elections[electionId].timestamp == 0,
            "Election already anchored"
        );

        elections[electionId] = ElectionRecord({
            electionId: electionId,
            merkleRoot: merkleRoot,
            voteCount: voteCount,
            timestamp: block.timestamp,
            anchoredBy: msg.sender
        });

        emit ElectionAnchored(electionId, merkleRoot, voteCount, block.timestamp);
    }

    function verifyElection(string memory electionId)
        external view returns (
            bytes32 merkleRoot,
            uint256 voteCount,
            uint256 timestamp
        )
    {
        ElectionRecord memory record = elections[electionId];
        require(record.timestamp > 0, "Election not found");
        return (record.merkleRoot, record.voteCount, record.timestamp);
    }
}
```

### Deploying the Contract

```bash
# Install Hardhat
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# hardhat.config.ts
import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
};

export default config;

# Deploy script
npx hardhat run scripts/deploy.ts --network mumbai
```

### Cloud Function — Anchor to Blockchain

```typescript
// functions/src/blockchain/anchorElection.ts
import { ethers } from "ethers";
import { CONTRACT_ABI } from "./abi";

const POLYGON_RPC = "https://rpc-mumbai.maticvigil.com";
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS!;
const PRIVATE_KEY = process.env.BLOCKCHAIN_PRIVATE_KEY!;

export async function anchorElectionToBlockchain(
  electionId: string,
  merkleRoot: string,
  voteCount: number
): Promise<string> {
  const provider = new ethers.JsonRpcProvider(POLYGON_RPC);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, wallet);

  const merkleRootBytes = ethers.hexlify(
    ethers.toUtf8Bytes(merkleRoot)
  ).padEnd(66, "0").slice(0, 66);

  const tx = await contract.anchorElection(
    electionId,
    merkleRootBytes,
    voteCount
  );

  const receipt = await tx.wait();
  return receipt.hash; // transaction hash
}
```

### Verifying on Public Portal

```typescript
// Verify election integrity from public verifier
export async function verifyElectionOnChain(electionId: string) {
  const provider = new ethers.JsonRpcProvider(POLYGON_RPC);
  const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider);

  const [merkleRoot, voteCount, timestamp] =
    await contract.verifyElection(electionId);

  return {
    merkleRoot,
    voteCount: Number(voteCount),
    timestamp: new Date(Number(timestamp) * 1000),
    polygonScanUrl: `https://mumbai.polygonscan.com/tx/${merkleRoot}`
  };
}
```

---

## 6. Database Schema — Firestore

### Collection Structure

```
firestore/
├── organizations/          {orgId}
├── elections/              {electionId}
├── positions/              {positionId}
├── candidates/             {candidateId}
├── voters/                 {userId}
├── kyc/                    {kycId}
├── votes/                  {voteId}
├── receipts/               {receiptId}
├── merkleNodes/            {nodeId}
├── anomalies/              {anomalyId}
├── auditLog/               {logId}
├── notifications/          {notifId}
└── admins/                 {userId}
```

### Document Schemas

#### organizations/{orgId}

```typescript
{
  id: string;
  name: string;                    // "City University Malaysia"
  domain: string;                  // "cityuni.edu.my"
  logo: string;                    // Storage URL
  status: "active" | "suspended";
  createdAt: Timestamp;
  createdBy: string;               // userId
  settings: {
    requireKYC: boolean;
    allowBiometric: boolean;
    defaultTimezone: string;       // "Asia/Kuala_Lumpur"
  };
}
```

#### elections/{electionId}

```typescript
{
  id: string;
  orgId: string;
  title: string;
  description: string;
  type: "single" | "multi" | "ranked";
  status: "draft" | "published" | "active" | "closed" | "results_published";
  createdBy: string;
  createdAt: Timestamp;
  schedule: {
    startTime: Timestamp;
    endTime: Timestamp;
    timezone: string;
    resultsVisibility: "after_close" | "live" | "admin_only";
  };
  eligibility: {
    type: "all_verified" | "segment" | "manual";
    rules: Array<{
      field: string;
      operator: string;
      value: string;
    }>;
    requireKYC: boolean;
    requireDeviceBinding: boolean;
    minimumTurnout: number;        // percentage 0-100
  };
  stats: {
    totalEligible: number;
    totalVoted: number;
    turnoutPercent: number;
  };
  blockchain: {
    merkleRoot: string;
    txHash: string;
    anchoredAt: Timestamp;
    network: "polygon_mumbai";
  };
  notifications: {
    openingReminder: boolean;
    midpointReminder: boolean;
    closingReminder: number;       // hours before close
  };
}
```

#### voters/{userId}

```typescript
{
  uid: string;
  email: string;
  phone: string;
  fullName: string;
  dateOfBirth: string;
  faculty: string;
  studentId: string;
  kycStatus: "not_submitted" | "pending" | "verified" | "rejected";
  kycSubmittedAt: Timestamp;
  kycReviewedAt: Timestamp;
  kycReviewedBy: string;          // admin userId
  kycRejectionReason: string;
  deviceBinding: {
    deviceId: string;
    deviceName: string;
    platform: string;             // "iOS" | "Android"
    registeredAt: Timestamp;
  };
  biometricEnabled: boolean;
  createdAt: Timestamp;
  lastActiveAt: Timestamp;
  status: "active" | "suspended";
}
```

#### votes/{voteId}

```typescript
{
  id: string;
  electionId: string;
  voterId: string;                // hashed for privacy — SHA256(userId)
  encryptedChoices: string;       // AES encrypted vote data
  receiptId: string;
  merkleLeaf: string;             // SHA256 hash of this vote
  submittedAt: Timestamp;
  deviceId: string;
  ipAddress: string;              // hashed
  userAgent: string;
  processingTime: number;         // milliseconds voter took
  status: "valid" | "flagged" | "invalidated";
}
```

#### receipts/{receiptId}

```typescript
{
  id: string;                     // "SV-2025-XK9M4P"
  electionId: string;
  voterId: string;                // hashed
  merkleLeaf: string;
  merkleProof: string[];          // array of sibling hashes
  merkleRoot: string;
  txHash: string;                 // blockchain tx hash
  timestamp: Timestamp;
  isPublic: boolean;
  verifiedCount: number;          // how many times verified
}
```

#### kyc/{kycId}

```typescript
{
  id: string;
  userId: string;
  idDocumentUrl: string;          // Firebase Storage URL
  selfieUrl: string;
  extractedData: {
    name: string;
    idNumber: string;             // partial masked
    confidence: number;           // AI extraction confidence %
  };
  livenessChecks: {
    blinkDetected: boolean;
    headTurnDetected: boolean;
    livePersonConfirmed: boolean;
    faceMatchScore: number;       // 0-100
  };
  riskScore: number;              // 0-100
  status: "pending" | "approved" | "rejected";
  reviewedBy: string;
  reviewedAt: Timestamp;
  rejectionReason: string;
  attempt: number;                // 1, 2, 3 max attempts
  submittedAt: Timestamp;
}
```

#### anomalies/{anomalyId}

```typescript
{
  id: string;
  electionId: string;
  ruleTriggered: string;          // "DUPLICATE_DEVICE" | "IP_VELOCITY" | etc.
  severity: "critical" | "high" | "medium" | "low";
  status: "open" | "investigating" | "resolved" | "dismissed";
  description: string;
  affectedVoterId: string;
  affectedDeviceId: string;
  ipAddress: string;
  detectedAt: Timestamp;
  resolvedAt: Timestamp;
  resolvedBy: string;
  metadata: Record<string, any>;  // rule-specific extra data
}
```

#### auditLog/{logId}

```typescript
{
  id: string;
  eventType: string;              // "VOTE_CAST" | "KYC_APPROVED" | etc.
  category: "auth" | "vote" | "kyc" | "election" | "security" | "system";
  actorId: string;
  actorType: "voter" | "admin" | "system";
  actorName: string;
  targetId: string;
  targetType: string;
  ipAddress: string;
  userAgent: string;
  status: "success" | "failed" | "pending";
  metadata: Record<string, any>;
  timestamp: Timestamp;
}
```

---

## 7. Authentication & Security

### Firebase Auth Setup

```typescript
// Admin Web — Next.js
import { initializeApp } from "firebase/app";
import { getAuth, signInWithEmailAndPassword,
         multiFactor, TotpMultiFactorGenerator } from "firebase/auth";

// Sign in with email + 2FA OTP
export async function adminSignIn(email: string, password: string, otp: string) {
  const auth = getAuth();
  try {
    await signInWithEmailAndPassword(auth, email, password);
    // 2FA handled by Firebase Multi-factor Auth
  } catch (error: any) {
    if (error.code === "auth/multi-factor-auth-required") {
      const resolver = getMultiFactorResolver(auth, error);
      const otpCredential = TotpMultiFactorGenerator.assertionForSignIn(
        resolver.hints[0].uid, otp
      );
      await resolver.resolveSignIn(otpCredential);
    }
  }
}
```

### Device Binding — Flutter

```dart
// services/device_binding_service.dart
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceBindingService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.id; // Android ID
    } else if (Platform.isIOS) {
      final info = await _deviceInfo.iosInfo;
      return info.identifierForVendor ?? '';
    }
    return '';
  }

  Future<bool> isDeviceBound(String userId) async {
    final deviceId = await getDeviceId();
    final voter = await FirebaseFirestore.instance
      .collection('voters')
      .doc(userId)
      .get();

    if (!voter.exists) return false;
    final binding = voter.data()?['deviceBinding'];
    if (binding == null) return false;
    return binding['deviceId'] == deviceId;
  }

  Future<void> bindDevice(String userId) async {
    final deviceId = await getDeviceId();
    final info = await _deviceInfo.androidInfo;
    await FirebaseFirestore.instance
      .collection('voters')
      .doc(userId)
      .update({
        'deviceBinding': {
          'deviceId': deviceId,
          'deviceName': info.model,
          'platform': Platform.operatingSystem,
          'registeredAt': FieldValue.serverTimestamp(),
        }
      });
  }
}
```

### Biometric Authentication — Flutter

```dart
// services/biometric_service.dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final isAvailable = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access SecureVote',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

### JWT Custom Claims — Cloud Function

```typescript
// functions/src/auth/setCustomClaims.ts
import * as admin from "firebase-admin";

export async function setAdminClaims(
  userId: string,
  role: "super_admin" | "org_admin" | "staff",
  orgId: string
) {
  await admin.auth().setCustomUserClaims(userId, {
    role,
    orgId,
    isAdmin: true,
  });
}

export async function setVoterClaims(userId: string) {
  await admin.auth().setCustomUserClaims(userId, {
    role: "voter",
    isAdmin: false,
  });
}
```

---

## 8. KYC Verification System

### Mobile — Photo Capture Flow

```dart
// screens/kyc/kyc_submission_screen.dart
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';

class KYCSubmissionService {

  // Step 1: Capture ID document
  Future<String> captureIDDocument(CameraController controller) async {
    final image = await controller.takePicture();
    return await _uploadToStorage(image.path, 'id_document');
  }

  // Step 2: Capture liveness selfie
  Future<String> captureSelfie(CameraController controller) async {
    final image = await controller.takePicture();
    return await _uploadToStorage(image.path, 'selfie');
  }

  // Upload to Firebase Storage
  Future<String> _uploadToStorage(String filePath, String type) async {
    final user = FirebaseAuth.instance.currentUser!;
    final ref = FirebaseStorage.instance
      .ref('kyc/${user.uid}/${type}_${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  // Submit KYC to Firestore
  Future<void> submitKYC(String idUrl, String selfieUrl) async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('kyc').add({
      'userId': user.uid,
      'idDocumentUrl': idUrl,
      'selfieUrl': selfieUrl,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'attempt': 1,
    });

    // Update voter KYC status
    await FirebaseFirestore.instance
      .collection('voters')
      .doc(user.uid)
      .update({'kycStatus': 'pending'});
  }
}
```

### Admin — KYC Review Cloud Function

```typescript
// functions/src/kyc/reviewKYC.ts
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export const reviewKYC = functions.https.onCall(async (data, context) => {
  // Verify admin is making this call
  if (!context.auth?.token.isAdmin) {
    throw new functions.https.HttpsError("permission-denied", "Admins only");
  }

  const { kycId, decision, rejectionReason } = data;
  const reviewerId = context.auth.uid;

  const kycRef = admin.firestore().collection("kyc").doc(kycId);
  const kycDoc = await kycRef.get();
  const kycData = kycDoc.data()!;

  // Update KYC document
  await kycRef.update({
    status: decision,                          // "approved" | "rejected"
    reviewedBy: reviewerId,
    reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    rejectionReason: rejectionReason || null,
  });

  // Update voter record
  await admin.firestore()
    .collection("voters")
    .doc(kycData.userId)
    .update({ kycStatus: decision });

  // Send push notification to voter
  const voterDoc = await admin.firestore()
    .collection("voters").doc(kycData.userId).get();
  const fcmToken = voterDoc.data()?.fcmToken;

  if (fcmToken) {
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: decision === "approved"
          ? "✅ Identity Verified!"
          : "❌ Verification Failed",
        body: decision === "approved"
          ? "You can now participate in eligible elections."
          : `Reason: ${rejectionReason}. Please resubmit.`,
      },
    });
  }

  // Write to audit log
  await admin.firestore().collection("auditLog").add({
    eventType: decision === "approved" ? "KYC_APPROVED" : "KYC_REJECTED",
    category: "kyc",
    actorId: reviewerId,
    actorType: "admin",
    targetId: kycData.userId,
    targetType: "voter",
    status: "success",
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});
```

---

## 9. Cryptographic Engine — Merkle Tree

### How It Works

```
All votes in an election = leaves of a Merkle tree

Each leaf = SHA256(voterId_hashed + timestamp + encryptedVote)

                    ┌─────────────┐
                    │  Merkle Root│  ← anchored to blockchain
                    └──────┬──────┘
               ┌───────────┴───────────┐
          ┌────┴────┐             ┌────┴────┐
          │  H(1,2) │             │  H(3,4) │
          └────┬────┘             └────┬────┘
        ┌──────┴──────┐       ┌────────┴────────┐
    ┌───┴───┐     ┌───┴───┐ ┌─┴───┐         ┌───┴───┐
    │ Vote1 │     │ Vote2 │ │Vote3│         │ Vote4 │
    └───────┘     └───────┘ └─────┘         └───────┘

Voter receipt includes:
- Their leaf hash
- The sibling hashes needed to reconstruct path to root
- The Merkle root itself

Anyone can verify: hash(leaf + siblings) == Merkle Root
```

### Merkle Tree — Cloud Function

```typescript
// functions/src/crypto/merkleTree.ts
import * as crypto from "crypto";

export function sha256(data: string): string {
  return crypto.createHash("sha256").update(data).digest("hex");
}

export function generateLeaf(
  voterIdHashed: string,
  timestamp: number,
  encryptedVote: string
): string {
  return sha256(`${voterIdHashed}:${timestamp}:${encryptedVote}`);
}

export function buildMerkleTree(leaves: string[]): {
  root: string;
  tree: string[][];
} {
  if (leaves.length === 0) return { root: "", tree: [] };

  let currentLevel = [...leaves];
  const tree: string[][] = [currentLevel];

  while (currentLevel.length > 1) {
    const nextLevel: string[] = [];
    for (let i = 0; i < currentLevel.length; i += 2) {
      const left = currentLevel[i];
      const right = currentLevel[i + 1] || left; // duplicate last if odd
      nextLevel.push(sha256(left + right));
    }
    currentLevel = nextLevel;
    tree.push(currentLevel);
  }

  return { root: currentLevel[0], tree };
}

export function getMerkleProof(
  leaves: string[],
  targetLeaf: string
): string[] {
  const { tree } = buildMerkleTree(leaves);
  const proof: string[] = [];
  let index = leaves.indexOf(targetLeaf);

  if (index === -1) return [];

  for (let level = 0; level < tree.length - 1; level++) {
    const isLeftNode = index % 2 === 0;
    const siblingIndex = isLeftNode ? index + 1 : index - 1;
    if (siblingIndex < tree[level].length) {
      proof.push(tree[level][siblingIndex]);
    }
    index = Math.floor(index / 2);
  }

  return proof;
}

export function verifyMerkleProof(
  leaf: string,
  proof: string[],
  root: string
): boolean {
  let current = leaf;
  for (const sibling of proof) {
    current = sha256(current + sibling);
  }
  return current === root;
}
```

### Generate Receipt — Cloud Function

```typescript
// functions/src/votes/castVote.ts
export const castVote = functions.https.onCall(async (data, context) => {
  const { electionId, encryptedChoices } = data;
  const userId = context.auth!.uid;

  // 1. Validate eligibility
  await validateVoterEligibility(userId, electionId);

  // 2. Check not already voted
  const existingVote = await checkExistingVote(userId, electionId);
  if (existingVote) throw new Error("Already voted");

  // 3. Generate vote data
  const timestamp = Date.now();
  const voterIdHashed = sha256(userId);
  const merkleLeaf = generateLeaf(voterIdHashed, timestamp, encryptedChoices);

  // 4. Store vote
  const voteRef = await admin.firestore().collection("votes").add({
    electionId,
    voterId: voterIdHashed,
    encryptedChoices,
    merkleLeaf,
    submittedAt: admin.firestore.FieldValue.serverTimestamp(),
    status: "valid",
  });

  // 5. Generate receipt ID
  const receiptId = `SV-${new Date().getFullYear()}-${generateShortId()}`;

  // 6. Get current leaves and generate proof
  const allVotes = await getElectionVotes(electionId);
  const leaves = allVotes.map(v => v.merkleLeaf);
  leaves.push(merkleLeaf);

  const { root } = buildMerkleTree(leaves);
  const proof = getMerkleProof(leaves, merkleLeaf);

  // 7. Store receipt
  await admin.firestore().collection("receipts").doc(receiptId).set({
    id: receiptId,
    electionId,
    voterId: voterIdHashed,
    merkleLeaf,
    merkleProof: proof,
    merkleRoot: root,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    isPublic: true,
  });

  // 8. Run anomaly check
  await runAnomalyChecks(userId, electionId, data.metadata);

  // 9. Return receipt to voter
  return {
    receiptId,
    merkleLeaf,
    merkleRoot: root,
    merkleProof: proof,
    timestamp,
  };
});
```

---

## 10. Anomaly Detection Engine

### 6 Rules Implementation

```typescript
// functions/src/anomaly/anomalyEngine.ts

interface VoteMetadata {
  deviceId: string;
  ipAddress: string;
  processingTime: number;    // ms voter took to vote
  latitude?: number;
  longitude?: number;
}

export async function runAnomalyChecks(
  userId: string,
  electionId: string,
  metadata: VoteMetadata
) {
  const checks = [
    checkDuplicateDevice(userId, electionId, metadata.deviceId),
    checkIPVelocity(electionId, metadata.ipAddress),
    checkOffHoursSubmission(electionId),
    checkRapidSubmission(metadata.processingTime),
    checkGeographicAnomaly(userId, metadata.latitude, metadata.longitude),
    checkVotingVelocitySpike(electionId),
  ];

  const results = await Promise.all(checks);
  for (const anomaly of results.filter(Boolean)) {
    await logAnomaly(anomaly!);
  }
}

// Rule 1: Duplicate Device
async function checkDuplicateDevice(
  userId: string, electionId: string, deviceId: string
) {
  const otherVotes = await admin.firestore()
    .collection("votes")
    .where("electionId", "==", electionId)
    .where("deviceId", "==", deviceId)
    .get();

  if (!otherVotes.empty) {
    return {
      ruleTriggered: "DUPLICATE_DEVICE_ID",
      severity: "critical",
      description: `Device ${deviceId} used by multiple voters`,
      affectedVoterId: userId,
      electionId,
    };
  }
  return null;
}

// Rule 2: IP Velocity Spike
async function checkIPVelocity(electionId: string, ipAddress: string) {
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
  const recentVotes = await admin.firestore()
    .collection("votes")
    .where("electionId", "==", electionId)
    .where("ipAddress", "==", ipAddress)
    .where("submittedAt", ">=", fiveMinutesAgo)
    .get();

  if (recentVotes.size >= 3) {
    return {
      ruleTriggered: "IP_VELOCITY_SPIKE",
      severity: "high",
      description: `${recentVotes.size} votes from IP ${ipAddress} in 5 minutes`,
      electionId,
    };
  }
  return null;
}

// Rule 3: Off-Hours Submission
async function checkOffHoursSubmission(electionId: string) {
  const election = await admin.firestore()
    .collection("elections").doc(electionId).get();
  const { startTime, endTime } = election.data()!.schedule;
  const now = Date.now();

  if (now < startTime.toMillis() || now > endTime.toMillis()) {
    return {
      ruleTriggered: "OFF_HOURS_SUBMISSION",
      severity: "critical",
      description: "Vote submitted outside election window",
      electionId,
    };
  }
  return null;
}

// Rule 4: Rapid Ballot Submission
async function checkRapidSubmission(processingTime: number) {
  if (processingTime < 10000) { // less than 10 seconds
    return {
      ruleTriggered: "RAPID_BALLOT_SUBMISSION",
      severity: "medium",
      description: `Ballot submitted in ${processingTime / 1000}s (< 10s threshold)`,
    };
  }
  return null;
}

// Rule 5: Geographic Anomaly
async function checkGeographicAnomaly(
  userId: string, lat?: number, lng?: number
) {
  if (!lat || !lng) return null;

  const voter = await admin.firestore()
    .collection("voters").doc(userId).get();
  const registeredLocation = voter.data()?.registeredLocation;
  if (!registeredLocation) return null;

  const distance = calculateDistance(
    lat, lng,
    registeredLocation.lat, registeredLocation.lng
  );

  if (distance > 500) { // km
    return {
      ruleTriggered: "GEOGRAPHIC_ANOMALY",
      severity: "medium",
      description: `Voter ${Math.round(distance)}km from registered location`,
      affectedVoterId: userId,
    };
  }
  return null;
}

// Rule 6: Voting Velocity Spike
async function checkVotingVelocitySpike(electionId: string) {
  const tenMinutesAgo = new Date(Date.now() - 10 * 60 * 1000);
  const recentVotes = await admin.firestore()
    .collection("votes")
    .where("electionId", "==", electionId)
    .where("submittedAt", ">=", tenMinutesAgo)
    .get();

  // Get previous 10 minute window for comparison
  const twentyMinutesAgo = new Date(Date.now() - 20 * 60 * 1000);
  const previousVotes = await admin.firestore()
    .collection("votes")
    .where("electionId", "==", electionId)
    .where("submittedAt", ">=", twentyMinutesAgo)
    .where("submittedAt", "<", tenMinutesAgo)
    .get();

  const spike = recentVotes.size / Math.max(previousVotes.size, 1);
  if (spike > 3) { // 3x velocity increase
    return {
      ruleTriggered: "VOTING_VELOCITY_SPIKE",
      severity: "high",
      description: `Vote velocity increased ${spike.toFixed(1)}x in last 10 minutes`,
      electionId,
    };
  }
  return null;
}

function calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLng/2) * Math.sin(dLng/2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}
```

---

## 11. Smart Election Assistant — Groq AI

### Cloud Function Implementation

```typescript
// functions/src/ai/electionAssistant.ts
import Groq from "groq-sdk";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

export const getElectionInsights = functions.https.onCall(
  async (data, context) => {
    if (!context.auth?.token.isAdmin) {
      throw new functions.https.HttpsError("permission-denied", "Admins only");
    }

    const { electionId } = data;
    const electionData = await gatherElectionData(electionId);

    const prompt = buildInsightPrompt(electionData);

    const response = await groq.chat.completions.create({
      model: "llama3-8b-8192",
      messages: [
        {
          role: "system",
          content: `You are SecureVote's election analysis AI. 
          You provide concise, data-driven insights for election administrators.
          Always respond in JSON format with these fields:
          {
            "currentStatus": "brief status summary",
            "predictedTurnout": number (0-100),
            "confidence": number (0-100),
            "riskLevel": "low" | "medium" | "high",
            "riskScore": number (0-100),
            "recommendations": [
              {
                "priority": "high" | "medium" | "low",
                "title": "action title",
                "description": "why and what to do",
                "action": "SEND_REMINDER" | "EXTEND_WINDOW" | "INVESTIGATE" | "NONE"
              }
            ],
            "anomalySummary": "brief anomaly analysis"
          }`
        },
        {
          role: "user",
          content: prompt
        }
      ],
      max_tokens: 800,
      temperature: 0.3,
    });

    const content = response.choices[0].message.content!;
    return JSON.parse(content.replace(/```json|```/g, "").trim());
  }
);

function buildInsightPrompt(data: ElectionData): string {
  return `
Analyze this election data and provide insights:

Election: ${data.title}
Status: ${data.status}
Time remaining: ${data.hoursRemaining} hours
Total eligible voters: ${data.totalEligible}
Votes cast: ${data.totalVoted}
Current turnout: ${data.turnoutPercent}%
Target turnout: ${data.targetTurnout}%
Votes per minute (last 30 min): ${data.voteVelocity}
Active anomalies: ${data.anomalyCount} (${data.criticalAnomalies} critical)
Historical similar elections avg turnout: ${data.historicalAvg}%

Provide analysis and recommendations.
  `;
}

async function gatherElectionData(electionId: string): Promise<ElectionData> {
  const election = await admin.firestore()
    .collection("elections").doc(electionId).get();
  const data = election.data()!;

  const votes = await admin.firestore()
    .collection("votes")
    .where("electionId", "==", electionId)
    .get();

  const anomalies = await admin.firestore()
    .collection("anomalies")
    .where("electionId", "==", electionId)
    .where("status", "==", "open")
    .get();

  const endTime = data.schedule.endTime.toMillis();
  const hoursRemaining = Math.max(0, (endTime - Date.now()) / 3600000);

  return {
    title: data.title,
    status: data.status,
    hoursRemaining: Math.round(hoursRemaining * 10) / 10,
    totalEligible: data.stats.totalEligible,
    totalVoted: votes.size,
    turnoutPercent: Math.round((votes.size / data.stats.totalEligible) * 100),
    targetTurnout: data.eligibility.minimumTurnout || 70,
    voteVelocity: await calculateVoteVelocity(electionId),
    anomalyCount: anomalies.size,
    criticalAnomalies: anomalies.docs.filter(
      d => d.data().severity === "critical"
    ).length,
    historicalAvg: 55, // placeholder — would query historical data
  };
}
```

---

## 12. Admin Web Portal — Implementation

### Project Setup

```bash
npx create-next-app@latest securevote-admin \
  --typescript \
  --tailwind \
  --app \
  --src-dir

cd securevote-admin
npm install firebase
npm install @/components/ui (shadcn)
npm install chart.js react-chartjs-2
npm install react-hook-form zod @hookform/resolvers
npm install ethers
npm install lucide-react
```

### Folder Structure

```
src/
├── app/
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── forgot-password/page.tsx
│   │   └── reset-password/page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx          ← sidebar + header
│   │   ├── page.tsx            ← dashboard
│   │   ├── elections/
│   │   │   ├── page.tsx        ← election list
│   │   │   ├── create/page.tsx ← wizard
│   │   │   └── [id]/
│   │   │       ├── page.tsx    ← overview
│   │   │       ├── ballot/page.tsx
│   │   │       └── candidates/page.tsx
│   │   ├── voters/
│   │   │   ├── page.tsx
│   │   │   ├── import/page.tsx
│   │   │   └── [id]/page.tsx
│   │   ├── monitoring/page.tsx
│   │   ├── results/page.tsx
│   │   ├── anomalies/page.tsx
│   │   ├── assistant/page.tsx
│   │   └── audit/page.tsx
│   └── verify/                 ← public verifier (no auth)
│       └── page.tsx
├── components/
│   ├── ui/                     ← shadcn components
│   ├── layout/
│   │   ├── Sidebar.tsx
│   │   └── Header.tsx
│   ├── elections/
│   ├── voters/
│   ├── charts/
│   └── shared/
├── lib/
│   ├── firebase.ts
│   ├── auth.ts
│   └── utils.ts
├── hooks/
│   ├── useElections.ts
│   ├── useVoters.ts
│   └── useRealtime.ts
└── types/
    └── index.ts
```

### Firebase Real-time Listener — Live Monitoring

```typescript
// hooks/useRealtime.ts
import { useEffect, useState } from "react";
import { collection, query, where,
         onSnapshot, orderBy, limit } from "firebase/firestore";
import { db } from "@/lib/firebase";

export function useLiveVotes(electionId: string) {
  const [votes, setVotes] = useState<Vote[]>([]);
  const [turnout, setTurnout] = useState(0);

  useEffect(() => {
    const q = query(
      collection(db, "votes"),
      where("electionId", "==", electionId),
      orderBy("submittedAt", "desc"),
      limit(50)
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const newVotes = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Vote[];
      setVotes(newVotes);
    });

    return () => unsubscribe();
  }, [electionId]);

  return { votes, turnout };
}

export function useLiveAnomalies(electionId: string) {
  const [anomalies, setAnomalies] = useState<Anomaly[]>([]);

  useEffect(() => {
    const q = query(
      collection(db, "anomalies"),
      where("electionId", "==", electionId),
      where("status", "==", "open"),
      orderBy("detectedAt", "desc")
    );

    return onSnapshot(q, (snapshot) => {
      setAnomalies(snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Anomaly[]);
    });
  }, [electionId]);

  return anomalies;
}
```

---

## 13. Voter Mobile App — Implementation

### Project Setup

```bash
flutter create securevote_app
cd securevote_app

# pubspec.yaml dependencies
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.14.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  firebase_messaging: ^14.7.0
  local_auth: ^2.1.6
  camera: ^0.10.5
  device_info_plus: ^9.1.0
  qr_flutter: ^4.1.0
  fl_chart: ^0.66.0
  go_router: ^12.0.0
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  shared_preferences: ^2.2.0
  crypto: ^3.0.3
  image_picker: ^1.0.4
  permission_handler: ^11.0.0
```

### App Architecture — Clean Architecture

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── utils/
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── onboarding_screen.dart
│   │       │   ├── welcome_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── login_screen.dart
│   │       └── providers/
│   ├── kyc/
│   │   └── presentation/screens/
│   │       ├── kyc_submission_screen.dart
│   │       └── kyc_status_screen.dart
│   ├── elections/
│   │   └── presentation/screens/
│   │       ├── home_screen.dart
│   │       ├── election_search_screen.dart
│   │       ├── election_detail_screen.dart
│   │       ├── candidate_detail_screen.dart
│   │       └── candidate_comparison_screen.dart
│   ├── voting/
│   │   └── presentation/screens/
│   │       ├── ballot_screen.dart
│   │       ├── review_vote_screen.dart
│   │       └── vote_success_screen.dart
│   ├── receipts/
│   │   └── presentation/screens/
│   │       ├── my_votes_screen.dart
│   │       └── receipt_detail_screen.dart
│   └── profile/
│       └── presentation/screens/
│           ├── profile_screen.dart
│           ├── edit_profile_screen.dart
│           └── notification_settings_screen.dart
└── shared/
    ├── widgets/
    └── providers/
```

### Vote Submission — Flutter

```dart
// features/voting/presentation/providers/vote_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class VoteState {
  final bool isLoading;
  final VoteReceipt? receipt;
  final String? error;
  const VoteState({this.isLoading = false, this.receipt, this.error});
}

class VoteNotifier extends StateNotifier<VoteState> {
  VoteNotifier() : super(const VoteState());

  Future<void> castVote({
    required String electionId,
    required Map<String, String> choices, // positionId: candidateId
  }) async {
    state = const VoteState(isLoading: true);

    try {
      // Encrypt choices client-side (simulation)
      final encryptedChoices = _encryptChoices(choices);

      // Get device metadata
      final deviceInfo = await _getDeviceMetadata();

      // Call Cloud Function
      final functions = FirebaseFunctions.instance;
      final result = await functions
        .httpsCallable('castVote')
        .call({
          'electionId': electionId,
          'encryptedChoices': encryptedChoices,
          'metadata': deviceInfo,
        });

      final data = result.data as Map<String, dynamic>;
      state = VoteState(
        receipt: VoteReceipt.fromMap(data),
      );
    } catch (e) {
      state = VoteState(error: e.toString());
    }
  }

  String _encryptChoices(Map<String, String> choices) {
    // AES-256 simulation using SHA-256 for demo
    final json = jsonEncode(choices);
    final bytes = utf8.encode(json);
    final hash = sha256.convert(bytes);
    return 'ENC:${hash.toString()}:${base64.encode(bytes)}';
  }

  Future<Map<String, dynamic>> _getDeviceMetadata() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return {
        'deviceId': info.id,
        'platform': 'Android',
        'processingTime': _ballotOpenTime != null
          ? DateTime.now().difference(_ballotOpenTime!).inMilliseconds
          : 0,
      };
    }
    return {};
  }
}
```

---

## 14. Public Verifier Portal

### Verify Receipt — Next.js Page

```typescript
// app/verify/page.tsx
"use client";
import { useState } from "react";
import { doc, getDoc } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { verifyMerkleProof } from "@/lib/crypto";
import { verifyElectionOnChain } from "@/lib/blockchain";

export default function VerifyPage() {
  const [receiptId, setReceiptId] = useState("");
  const [result, setResult] = useState<VerifyResult | null>(null);
  const [loading, setLoading] = useState(false);

  async function verifyReceipt() {
    setLoading(true);
    try {
      // 1. Fetch receipt from Firestore
      const receiptDoc = await getDoc(doc(db, "receipts", receiptId));
      if (!receiptDoc.exists()) {
        setResult({ verified: false, reason: "Receipt not found" });
        return;
      }

      const receipt = receiptDoc.data();

      // 2. Verify Merkle proof locally
      const isValidProof = verifyMerkleProof(
        receipt.merkleLeaf,
        receipt.merkleProof,
        receipt.merkleRoot
      );

      // 3. Verify Merkle root on blockchain
      const onChainData = await verifyElectionOnChain(receipt.electionId);
      const isOnChain = onChainData.merkleRoot === receipt.merkleRoot;

      setResult({
        verified: isValidProof && isOnChain,
        receipt,
        merkleVerified: isValidProof,
        blockchainVerified: isOnChain,
        onChainData,
      });
    } finally {
      setLoading(false);
    }
  }

  return (
    // UI implementation using Stitch designs
    <main>...</main>
  );
}
```

---

## 15. API Design

### Cloud Functions Endpoints

| Function | Type | Auth | Description |
|----------|------|------|-------------|
| `castVote` | Callable | Voter | Submit encrypted vote |
| `reviewKYC` | Callable | Admin | Approve/reject KYC |
| `closeElection` | Callable | Admin | Close + anchor to blockchain |
| `getElectionInsights` | Callable | Admin | Groq AI analysis |
| `publishResults` | Callable | Admin | Make results public |
| `verifyReceipt` | HTTP GET | Public | Verify vote receipt |
| `sendVoterReminder` | Callable | Admin | Push notification to voters |
| `runAnomalyReport` | Callable | Admin | Full anomaly analysis |
| `importVoters` | Callable | Admin | Bulk CSV voter import |
| `generateAuditExport` | Callable | Admin | Export audit log CSV |

### Close Election + Anchor Function

```typescript
// functions/src/elections/closeElection.ts
export const closeElection = functions.https.onCall(async (data, context) => {
  const { electionId } = data;

  // 1. Get all votes
  const votes = await admin.firestore()
    .collection("votes")
    .where("electionId", "==", electionId)
    .where("status", "==", "valid")
    .get();

  const leaves = votes.docs.map(d => d.data().merkleLeaf);

  // 2. Build final Merkle tree
  const { root } = buildMerkleTree(leaves);

  // 3. Update all receipts with final root
  const batch = admin.firestore().batch();
  for (const receiptDoc of votes.docs) {
    const receiptRef = admin.firestore()
      .collection("receipts")
      .doc(receiptDoc.data().receiptId);
    batch.update(receiptRef, { merkleRoot: root });
  }
  await batch.commit();

  // 4. Anchor to Polygon blockchain
  const txHash = await anchorElectionToBlockchain(
    electionId, root, votes.size
  );

  // 5. Update election with blockchain data
  await admin.firestore().collection("elections").doc(electionId).update({
    status: "closed",
    "blockchain.merkleRoot": root,
    "blockchain.txHash": txHash,
    "blockchain.anchoredAt": admin.firestore.FieldValue.serverTimestamp(),
    "blockchain.network": "polygon_mumbai",
    closedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { merkleRoot: root, txHash, voteCount: votes.size };
});
```

---

## 16. Development Phase Plan

### Phase 1 — Core Foundation (Weeks 1–4)

```
Week 1:
  ✅ Firebase project setup
  ✅ Firestore schema + security rules
  ✅ Firebase Auth (email + 2FA)
  ✅ Admin login screen (Next.js)
  ✅ Flutter project setup + Firebase connection
  ✅ Mobile auth screens (register + login)

Week 2:
  ✅ Admin dashboard (basic KPIs)
  ✅ Election List + Create Election (basic info + schedule)
  ✅ Mobile home screen + election list
  ✅ Mobile election detail screen

Week 3:
  ✅ Voter management (list + add + import CSV)
  ✅ KYC submission flow (mobile)
  ✅ KYC review screen (admin)
  ✅ Cloud Function: reviewKYC

Week 4:
  ✅ Basic voting flow (ballot + confirm + success)
  ✅ Cloud Function: castVote (basic without crypto)
  ✅ Results dashboard (simple vote count)
  🎯 MILESTONE: Admin creates election → Voter votes → Admin sees count
```

### Phase 2 — Security + Crypto (Weeks 5–9)

```
Week 5–6:
  ✅ Biometric login (Flutter local_auth)
  ✅ Device binding implementation
  ✅ Merkle tree engine (Cloud Functions)
  ✅ Vote receipt generation
  ✅ Receipt detail screen (mobile)

Week 7–8:
  ✅ Anomaly detection engine (all 6 rules)
  ✅ Anomaly alerts screen (admin)
  ✅ Live monitoring dashboard
  ✅ Real-time Firebase listeners

Week 9:
  ✅ Smart contract deployment (Polygon Mumbai)
  ✅ Blockchain anchoring function
  ✅ Public verifier portal
  🎯 MILESTONE: Full secure vote → receipt → verify on blockchain
```

### Phase 3 — AI + Polish (Weeks 10–14)

```
Week 10–11:
  ✅ Groq AI integration (Smart Assistant)
  ✅ Turnout prediction
  ✅ Audit log (full implementation)
  ✅ Push notifications (FCM)

Week 12–13:
  ✅ All remaining screens (both apps)
  ✅ Candidate comparison
  ✅ Election results with charts
  ✅ Dark mode on web

Week 14:
  ✅ QA testing
  ✅ Bug fixes
  ✅ Performance optimization
  ✅ Deployment
  🎯 MILESTONE: Full system demo-ready
```

---

## 17. Folder Structure

### Monorepo Structure

```
securevote/
├── apps/
│   ├── web/                        ← Next.js Admin Portal
│   │   ├── src/
│   │   ├── public/
│   │   ├── .env.local
│   │   └── package.json
│   └── mobile/                     ← Flutter Voter App
│       ├── lib/
│       ├── android/
│       ├── ios/
│       ├── .env
│       └── pubspec.yaml
├── functions/                      ← Firebase Cloud Functions
│   ├── src/
│   │   ├── auth/
│   │   ├── votes/
│   │   ├── kyc/
│   │   ├── crypto/
│   │   ├── anomaly/
│   │   ├── ai/
│   │   ├── blockchain/
│   │   └── index.ts
│   ├── package.json
│   └── tsconfig.json
├── contracts/                      ← Solidity Smart Contract
│   ├── SecureVoteAnchor.sol
│   ├── scripts/deploy.ts
│   └── hardhat.config.ts
├── firestore.rules
├── storage.rules
├── firebase.json
└── README.md
```

---

## 18. Environment Variables

### Web — .env.local

```env
# Firebase
NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=

# Blockchain
NEXT_PUBLIC_CONTRACT_ADDRESS=
NEXT_PUBLIC_POLYGON_RPC=https://rpc-mumbai.maticvigil.com
```

### Cloud Functions — .env

```env
GROQ_API_KEY=
BLOCKCHAIN_PRIVATE_KEY=
CONTRACT_ADDRESS=
```

### Flutter — .env (via flutter_dotenv)

```env
FIREBASE_WEB_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
```

---

## 19. Deployment Guide

### Web — Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
cd apps/web
vercel deploy --prod

# Set environment variables in Vercel dashboard
# or via CLI:
vercel env add NEXT_PUBLIC_FIREBASE_API_KEY
```

### Cloud Functions — Firebase

```bash
cd functions
npm run build
firebase deploy --only functions
```

### Mobile — Android APK

```bash
cd apps/mobile
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk
```

### Mobile — iOS (requires Mac + Apple Developer)

```bash
flutter build ios --release
```

### Smart Contract — Polygon Mumbai

```bash
cd contracts
npx hardhat run scripts/deploy.ts --network mumbai
# Save the deployed contract address to .env
```

---

## 20. Testing Strategy

### Unit Tests — Cloud Functions

```typescript
// functions/src/__tests__/merkleTree.test.ts
import { buildMerkleTree, verifyMerkleProof, getMerkleProof } from "../crypto/merkleTree";

describe("Merkle Tree", () => {
  test("builds correct root for 4 leaves", () => {
    const leaves = ["a", "b", "c", "d"].map(l =>
      require("crypto").createHash("sha256").update(l).digest("hex")
    );
    const { root } = buildMerkleTree(leaves);
    expect(root).toHaveLength(64);
  });

  test("verifies valid proof", () => {
    const leaves = ["vote1", "vote2", "vote3", "vote4"];
    const { root } = buildMerkleTree(leaves);
    const proof = getMerkleProof(leaves, "vote2");
    expect(verifyMerkleProof("vote2", proof, root)).toBe(true);
  });

  test("rejects tampered proof", () => {
    const leaves = ["vote1", "vote2", "vote3"];
    const { root } = buildMerkleTree(leaves);
    const proof = getMerkleProof(leaves, "vote1");
    expect(verifyMerkleProof("tampered", proof, root)).toBe(false);
  });
});
```

### Widget Tests — Flutter

```dart
// test/voting/ballot_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Ballot screen shows candidates', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BallotScreen(electionId: 'test-election'),
    ));
    expect(find.text('Cast Your Vote'), findsOneWidget);
  });

  testWidgets('Submit button disabled until selection made', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BallotScreen(electionId: 'test-election'),
    ));
    final button = find.text('Next');
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
  });
}
```

### Integration Test Checklist

```
[ ] Admin can create election end-to-end
[ ] Voter can register and complete KYC submission
[ ] Admin can approve KYC
[ ] Voter can cast vote after KYC approved
[ ] Receipt is generated with valid Merkle proof
[ ] Merkle proof verification passes on public verifier
[ ] Anomaly detection triggers on duplicate device
[ ] Blockchain anchoring completes after election close
[ ] AI assistant returns valid JSON response
[ ] Push notification delivered after KYC decision
[ ] Device binding blocks second device login
[ ] Biometric login works after initial setup
```

---

## Summary

| Component | Technology | Status |
|-----------|-----------|--------|
| Admin Web | Next.js 14 + TypeScript + Tailwind | Plan ready |
| Voter Mobile | Flutter + Dart | Plan ready |
| Database | Firebase Firestore | Schema defined |
| Auth | Firebase Auth + 2FA + Biometric | Spec defined |
| Storage | Firebase Storage | Rules defined |
| Backend | Firebase Cloud Functions | Code ready |
| AI | Groq API (llama3-8b-8192) | Code ready |
| Blockchain | Polygon Mumbai + Solidity | Contract ready |
| Crypto | Merkle Tree + SHA-256 | Code ready |
| Fraud Detection | Rule-based engine (6 rules) | Code ready |
| Hosting | Vercel (web) + Firebase (functions) | Guide ready |

---

> **SecureVote** — Built by Nexauro
> Islam MD Rakibul · City University Malaysia · 2025
