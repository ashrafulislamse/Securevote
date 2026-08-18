# Chapter 3: Methodology

## 3.1 Introduction

This chapter describes the methodology adopted for developing the SecureVote blockchain voting system. SecureVote is a mobile application that enables voters to register, complete identity verification, browse elections, cast votes, and verify their ballots through cryptographic receipts. The system also includes an administrative web portal for election management and a backend API deployed on Cloudflare Workers.

The methodology covers the system development model, data flow diagrams, requirement analysis, and software and hardware specifications. These elements provide the blueprint for the system design and implementation described in Chapters 4 and 5. The project was developed over a 16-week period using the Agile methodology, which was chosen for its flexibility and iterative nature.

## 3.2 System Development Model

### 3.2.1 Agile Methodology

The SecureVote project was developed using the Agile methodology, an iterative approach that breaks the project into small development cycles called sprints. Agile was chosen because the project spans multiple technology domains — mobile development, web portal, backend API, and blockchain integration — each with independent risk profiles that benefit from iterative validation. The Agile approach allowed the development team to build core features first, test them, and then add more complex integrations such as blockchain anchoring and KYC verification.

Agile divides the project into short development cycles, known as sprints, where each sprint delivers a usable and testable portion of the system. This approach ensures that feedback from testing and supervisor reviews is continuously incorporated into the system, leading to an application that meets real-world needs effectively (Beck et al., 2001).

![](diagrams/agile-process.png)

**Figure 1.** Agile methodology process showing iterative sprint cycles from requirement analysis through deployment and feedback.

### 3.2.2 Agile Phases Applied

The Agile process for SecureVote followed five phases within each sprint:

**Requirement Analysis.** During this phase, the needs and constraints of target users were identified. Information was collected through literature review of existing e-voting systems and analysis of user requirements. Both functional requirements — such as user registration, KYC verification, vote casting, and receipt generation — and non-functional requirements — such as performance, security, and scalability — were defined and organized into a prioritized product backlog.

**Design.** The design phase transformed conceptual ideas into structured wireframes and prototypes. Using Flutter's widget system, the team created interface designs for each key screen, including the home page, ballot screen, receipt screen, and admin dashboard. Modern design principles were applied to ensure a visually consistent and accessible interface.

**Development.** The approved designs were translated into functional software. The mobile application was built using Flutter and Dart, the web portal using Next.js and React, and the backend using Cloudflare Workers with Hono. Development followed two-week sprint cycles, each focusing on specific modules such as authentication, KYC submission, voting, and blockchain integration.

**Quality Assurance.** Testing was integrated throughout the development process. Functional testing verified that each feature worked as intended. Usability testing evaluated how easily users could move through the app. Security testing confirmed that authentication, authorization, and data protection mechanisms were effective.

**Deployment and Feedback.** After testing, the system was deployed to production environments on Cloudflare Workers and Pages. Feedback from supervisor demonstrations and testing was analyzed and incorporated into the next sprint cycle, ensuring continuous improvement.

### 3.2.3 Sprint Schedule

The project was divided into 8 sprints over 16 weeks:

**Table 1.** Sprint schedule for SecureVote development.

| Sprint | Weeks | Focus | Key Deliverables |
|---|---|---|---|
| 1–2 | 1–4 | Foundation | Development environment setup, project structure, basic authentication |
| 3–4 | 5–8 | Core Features | KYC verification, election browsing, candidate management |
| 5–6 | 9–12 | Voting System | Ballot casting, vote encryption, receipt generation, duplicate prevention |
| 7–8 | 13–16 | Integration | Blockchain anchoring, admin portal, testing, deployment |

## 3.3 Data Flow Diagrams

A data flow diagram (DFD) provides a visual representation of how data moves through a system. For SecureVote, the DFD illustrates how voter information, election data, and vote records flow between users, the application, the backend, and external services. Two levels of DFD are presented: a context diagram showing the system at a high level, and a Level 1 diagram breaking the system into its major functional components.

### 3.3.1 Context Diagram (DFD Level 0)

![](diagrams/context-diagram.png)

**Figure 2.** SecureVote context diagram showing the system at the centre and external entities: voters, administrators, Cloudflare D1 database, R2 storage, Polygon blockchain, and the public verifier.

The context diagram shows SecureVote interacting with the following external entities:

- **Voters** — access the platform via the Flutter mobile application for registration, KYC, voting, and receipt verification
- **Administrators** — access the Next.js web portal for election management, KYC review, and audit monitoring
- **Cloudflare D1** — stores user profiles, elections, candidates, votes, and audit records
- **Cloudflare R2** — stores KYC document images securely
- **Polygon blockchain** — anchors election Merkle roots for tamper-evident verification
- **Public verifier** — any user can verify a vote receipt through the public endpoint without authentication

### 3.3.2 Level 1 Data Flow Diagram

![](diagrams/dfd-level1.png)

**Figure 3.** Level 1 data flow diagram for SecureVote showing major processes: authentication, KYC verification, election management, vote casting, receipt generation, and blockchain anchoring.

The Level 1 DFD illustrates the detailed data flow within SecureVote:

1. **User Registration and Authentication** — voters create accounts with email and password. The system sends an OTP via email, verifies it, and establishes a session stored in Cloudflare KV. Authentication data is stored in the D1 database.

2. **KYC Verification** — voters upload identity documents through the Flutter app. Documents are stored in Cloudflare R2, and a KYC record is created in D1. Administrators review submissions through the web portal, approve or reject them, and the system notifies the voter.

3. **Election Management** — administrators create elections with titles, dates, and candidate information through the web portal. Election data is stored in D1 and made available to voters through the API.

4. **Vote Casting** — verified voters select candidates on the ballot screen. The system encrypts vote data, generates a SHA-256 vote hash, creates a unique receipt ID, and stores the vote in D1 with a UNIQUE constraint preventing duplicate voting.

5. **Receipt Generation** — after vote submission, the system generates a cryptographic receipt containing the receipt ID, vote hash, and Merkle proof. Voters can verify their receipt through the public verifier endpoint.

6. **Blockchain Anchoring** — when an election closes, the system computes a Merkle root from all vote hashes and anchors it to the Polygon blockchain via a Solidity smart contract. The transaction hash and block number are stored with the election record.

## 3.4 Requirement Analysis

A comprehensive analysis of both functional and non-functional requirements was essential to ensure that SecureVote remains practical, reliable, and secure for its intended users. The primary functional requirements focus on enabling voters to register, complete identity verification, browse elections, cast votes, and verify receipts from their mobile devices. The non-functional requirements define the quality attributes the system must uphold, including performance, security, reliability, and scalability.

By identifying these requirements early in the development process, the project ensured that every design and implementation decision aligned with the core objective: providing a secure, transparent, and accessible electronic voting system.

## 3.5 Functional Requirements

**Table 2.** Functional requirements of the SecureVote system.

| No | Requirement | Description |
|---|---|---|
| FR-01 | User Registration and Login | Users can create an account and log in securely using email and password. An OTP code is sent to the email for verification. Roles (voter, admin) control access privileges. |
| FR-02 | KYC Verification | Voters upload government ID documents and a selfie photo. Documents are stored securely in cloud storage. Administrators review and approve or reject submissions. Voters are notified of status changes. |
| FR-03 | Election Management | Administrators can create elections with title, description, start and end dates. Candidates can be added with photos, party affiliation, and manifestos. Election status follows a workflow: draft, scheduled, active, closed, published. |
| FR-04 | Vote Casting | Verified voters can browse active elections, view candidate details, select candidates on the ballot, review their selections, and submit their vote. The system prevents duplicate voting through a database constraint. |
| FR-05 | Receipt Generation | After vote submission, the system generates a unique receipt ID and a SHA-256 vote hash. A QR code is displayed for verification. Voters can view their vote history and receipts. |
| FR-06 | Public Vote Verification | Any user can verify a vote receipt through the public endpoint by entering the receipt ID. The system returns the election title, vote hash, and blockchain anchor details without revealing the voter identity or selections. |
| FR-07 | Blockchain Anchoring | When an election closes, the system computes a Merkle root from all vote hashes and anchors it to the Polygon blockchain via a smart contract. The transaction hash and block number are stored with the election. |
| FR-08 | Admin Dashboard | Administrators have access to a web portal with dashboard statistics, voter registry, election management, KYC review queue, audit log, and anomaly alerts. |
| FR-09 | Notifications | The system sends in-app and email notifications for KYC status changes, vote confirmation, and election status updates. |
| FR-10 | Audit Logging | Every privileged action is recorded in an audit log with actor, target, metadata, and IP address. The audit log uses a hash chain for tamper detection. |

## 3.6 Non-Functional Requirements

**Table 3.** Non-functional requirements of the SecureVote system.

| No | Requirement | Description |
|---|---|---|
| NFR-01 | Usability | The mobile app interface must be intuitive and accessible for users with basic smartphone proficiency. The voting process requires no more than 5 steps from login to confirmation. |
| NFR-02 | Performance | The app should launch within 3 seconds on standard devices. Vote submission should complete within 5 seconds under normal network conditions. Dashboard data should load within 2 seconds. |
| NFR-03 | Security | All communication uses HTTPS with TLS encryption. Passwords are hashed using PBKDF2-SHA256 with 100,000 iterations. JWT tokens are used for session management. Rate limiting prevents brute force attacks. |
| NFR-04 | Reliability | The system should maintain high availability during election periods. Data is stored in Cloudflare D1 with automatic backups. The system handles network interruptions gracefully. |
| NFR-05 | Scalability | The system should support multiple concurrent elections and up to 10,000 voters. Cloudflare Workers scale automatically to handle varying loads. |
| NFR-06 | Compatibility | The mobile app runs on Android 8.0 and above. The web portal is compatible with modern browsers including Chrome, Firefox, and Safari. |
| NFR-07 | Maintainability | Code follows consistent style guidelines with modular architecture and clear separation of concerns. Version control is maintained through Git and GitHub. |
| NFR-08 | Privacy | Voter identity is never linked to vote selections in public records. The public verifier returns only receipt metadata, not user information or choices. |

## 3.7 Software Specifications

**Table 4.** Software specifications for the SecureVote system.

| Category | Specification | Purpose |
|---|---|---|
| IDE | Visual Studio Code | Code editing, debugging, and integrated terminal |
| Mobile Framework | Flutter 3.x (stable channel) | Cross-platform mobile application development |
| Mobile Language | Dart 3.x | Programming language for Flutter applications |
| Web Framework | Next.js 16 with React 19 | Admin web portal with server-side rendering |
| Web Language | TypeScript | Type-safe development for web portal |
| Backend Framework | Hono on Cloudflare Workers | Lightweight API framework for edge computing |
| Backend Language | TypeScript | Type-safe backend development |
| Database | Cloudflare D1 (SQLite at edge) | User, election, and vote data storage |
| File Storage | Cloudflare R2 | KYC document and image storage |
| Cache | Cloudflare KV | Session management and rate limiting |
| Blockchain | Polygon Amoy testnet | Vote anchoring and verification |
| Smart Contract Language | Solidity 0.8.24 | Blockchain contract development |
| Blockchain Tools | Hardhat, ethers v6 | Smart contract testing and deployment |
| API Testing | Postman | Backend API testing and validation |
| Version Control | Git and GitHub | Source code management |
| State Management | Provider (Flutter) | Application state management |
| HTTP Client | Dio 5.x (Flutter) | API communication with auto-refresh |
| Secure Storage | flutter_secure_storage | JWT token storage (Keychain/Keystore) |
| UI Styling | Tailwind CSS 4.x | Web portal styling |
| Email Service | Resend | OTP email delivery |

## 3.8 Hardware Specifications

**Table 5.** Hardware specifications for the SecureVote system.

| Component | Specification | Purpose |
|---|---|---|
| Development Machine | Intel i5/AMD Ryzen 5 or better, 8 GB RAM minimum, 20 GB free storage | Application development and testing |
| Voter Smartphone | Android 8.0+ (API 26+), 2 GB RAM minimum, camera for KYC | Running the voter mobile application |
| Admin Computer | Windows 10+ or macOS, 4 GB RAM, modern browser | Accessing the administrative web portal |
| Server Infrastructure | Cloudflare Workers (edge network) | Backend API hosting with automatic scaling |
| Database Server | Cloudflare D1 (managed SQLite) | Data storage with edge replication |
| File Storage | Cloudflare R2 (S3-compatible) | KYC document storage |
| Internet Connection | Stable 4G/Wi-Fi | Communication between app and backend |

## 3.9 Conclusion

This chapter outlined the methodology adopted for developing the SecureVote blockchain voting system. The Agile methodology was chosen for its flexibility, iterative nature, and ability to accommodate changing requirements across multiple technology domains. Requirement analysis identified the functional and non-functional needs of voters and administrators, ensuring the system is user-centred and practical. Data flow diagrams provided a visual blueprint of how data moves through the system, from voter registration through blockchain anchoring. The software and hardware specifications defined the tools and infrastructure required for development and deployment. Together, these elements establish a strong foundation for the system design described in Chapter 4 and the implementation and testing described in Chapter 5.

## References

Beck, K., Beedle, M., van Bennekum, A., Cockburn, A., Cunningham, W., Fowler, M., Grenning, J., Highsmith, J., Hunt, A., Jeffries, R., Kern, J., Marick, B., Martin, R. C., Mellor, S., Schwaber, K., Sutherland, J., & Thomas, D. (2001). *Manifesto for Agile software development*. Retrieved from https://agilemanifesto.org

Pressman, R. S., & Maxim, B. R. (2020). *Software engineering: A practitioner's approach* (9th ed.). McGraw-Hill Education.

Sommerville, I. (2016). *Software engineering* (10th ed.). Pearson.
