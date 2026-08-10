# SecureVote: Blockchain-Based Electronic Voting System
## University Project Report

---

### Project Information

**Project Title:** SecureVote - Design and Implementation of a Secure Online Voting System  
**Student Name:** Islam MD Rakibul  
**Student ID:** 202305010188  
**Program:** Bachelor of Information Technology  
**Institution:** City University Malaysia  
**Department:** Computer Science / Information Technology  
**Academic Year:** 2025/2026  
**Submission Date:** March 29, 2026

---

## Abstract

This project presents SecureVote, a comprehensive blockchain-based electronic voting application designed to revolutionize democratic processes through modern technology. The system addresses critical challenges in traditional voting systems including security vulnerabilities, lack of transparency, voter accessibility issues, and result verification difficulties.

SecureVote implements a complete end-to-end voting solution consisting of three integrated platforms: an Admin Web Portal built with Next.js 14 for election management, a cross-platform Voter Mobile Application developed using Flutter for iOS and Android, and a Public Verifier Portal for transparent vote verification. The system leverages Firebase ecosystem for real-time data management, Polygon blockchain for immutable record anchoring, and advanced cryptographic techniques including Merkle tree structures for vote verification.

Key innovations include Know Your Customer (KYC) verification with biometric authentication, device binding for duplicate vote prevention, end-to-end encryption simulation, AI-powered election assistance using Groq API, real-time anomaly detection, and cryptographic receipt generation. The implementation demonstrates how distributed ledger technology combined with modern mobile frameworks can create secure, transparent, and accessible voting systems.

The project successfully delivers a working prototype with 47 mobile screens, 24 web portal screens, complete authentication flows, and blockchain integration. Testing validates the system's ability to prevent duplicate voting, maintain voter privacy, generate verifiable receipts, and provide real-time monitoring capabilities. Results show 95.4% test pass rate, 100% blockchain anchoring success, and 4.2/5 user satisfaction rating.

**Keywords:** Electronic Voting, Blockchain Technology, Mobile Application, Flutter, Firebase, Cryptography, Merkle Tree, KYC Verification, Biometric Authentication, Smart Contracts, Polygon, Democratic Technology

---

## Declaration

I hereby declare that this project report titled "SecureVote: Blockchain-Based Electronic Voting System" is my original work conducted under the supervision of [Supervisor Name] at City University Malaysia. All sources of information, code libraries, frameworks, and references have been properly acknowledged and cited throughout this document.

This work has not been submitted previously for any other degree or qualification at this or any other institution. The implementation, design decisions, and analysis presented herein represent my own understanding and application of the technologies involved.

**Student Signature:** _______________  
**Date:** March 29, 2026

---

## Acknowledgments

I would like to express my sincere gratitude to all those who contributed to the successful completion of this project:

First and foremost, I thank my project supervisor, [Supervisor Name], for their invaluable guidance, constructive feedback, and continuous support throughout the development lifecycle. Their expertise in software engineering and security systems significantly shaped the direction of this project.

I am grateful to the Faculty of Information Technology at City University Malaysia for providing the necessary resources, development environment, and academic framework that enabled this research.

Special thanks to the open-source community, particularly the Flutter, Firebase, and Ethereum development communities, whose documentation, tools, and frameworks formed the foundation of this implementation.

I acknowledge Google Firebase for providing free-tier cloud services that made real-time database management and authentication possible, and Polygon for offering testnet infrastructure for blockchain integration.

Finally, I thank my family and friends for their unwavering encouragement and patience during the intensive development and documentation phases of this project.

---

## Table of Contents

### Chapter 1: Introduction
1.1 Project Background  
1.2 Problem Statement  
1.3 Project Purpose and Motivation  
1.4 Project Objectives  
1.5 Rationale for Blockchain-Based Voting  
1.6 Significance of the Study  
1.7 Scope of the Project  
1.8 Limitations and Constraints  
1.9 Project Organization  
1.10 Report Structure

### Chapter 2: Literature Review
2.1 Introduction to Electronic Voting Systems  
2.2 Evolution of Voting Technologies  
2.3 Blockchain Technology Fundamentals  
2.4 Cryptographic Techniques in Voting  
2.5 Mobile Application Development for Secure Systems  
2.6 Review of Existing E-Voting Research and Systems  
2.7 Comparison of Existing Methods  
2.8 Selectivity Statement and Critical Analysis  
2.9 Gap Analysis and Relation to Proposed System  
2.10 Survey Findings and User Requirements  
2.11 Research Gap Summary  
2.12 Proposed System Improvements  
2.13 Literature Review Conclusion

### Chapter 3: Methodology
3.1 Introduction  
3.2 System Analysis and Requirements  
   3.2.1 Current System Analysis  
   3.2.2 Proposed System Overview  
   3.2.3 Feasibility Study  
   3.2.4 Functional Requirements  
   3.2.5 Non-Functional Requirements  
3.3 System Design and Architecture  
   3.3.1 System Architecture Overview  
   3.3.2 Database Design  
   3.3.3 User Interface Design  
   3.3.4 Security Architecture  
   3.3.5 Blockchain Integration Design  
3.4 Software Development Methodology  
   3.4.1 Agile Methodology  
   3.4.2 Development Environment  
   3.4.3 Technology Stack Selection  
   3.4.4 Development Phases  
3.5 Implementation  
   3.5.1 Authentication System  
   3.5.2 KYC Verification Module  
   3.5.3 Voting Mechanism  
   3.5.4 Blockchain Integration  
   3.5.5 Merkle Tree Engine  
   3.5.6 Anomaly Detection  
3.6 Testing and Quality Assurance  
   3.6.1 Testing Strategy  
   3.6.2 Test Cases and Results  
   3.6.3 Performance Testing  
   3.6.4 Security Testing  
3.7 Results and Evaluation  
   3.7.1 System Functionality  
   3.7.2 Performance Analysis  
   3.7.3 Achievement of Objectives  
3.8 Conclusion

### References

### Appendices
Appendix A: User Manual  
Appendix B: Installation Guide  
Appendix C: Source Code Structure  
Appendix D: Database Schema Details  
Appendix E: API Documentation  
Appendix F: Test Cases and Results  
Appendix G: Screenshots Gallery  
Appendix H: Smart Contract Code  
Appendix I: Environment Variables  
Appendix J: Glossary of Terms  
Appendix K: Project Timeline  
Appendix L: Acknowledgment of Tools

---

## List of Figures

Figure 1.1: Traditional vs Electronic Voting Comparison  
Figure 2.1: Blockchain Structure Diagram  
Figure 2.2: Evolution of Voting Technologies Timeline  
Figure 3.1: SecureVote System Architecture  
Figure 3.2: Three-Tier Architecture Diagram  
Figure 3.3: Firestore Database Schema  
Figure 3.4: Vote Submission Data Flow  
Figure 3.5: Merkle Tree Structure  
Figure 3.6: Authentication Flow Diagram  
Figure 3.7: KYC Verification Process  
Figure 3.8: Use Case Diagram  
Figure 3.9: Sequence Diagram - Vote Casting  
Figure 3.10: Smart Contract Deployment Process  
Figure 3.11: Testing Pyramid  
Figure 3.12: Performance Metrics Dashboard

---

## List of Tables

Table 1.1: Project Scope Summary  
Table 2.1: Comparison of Blockchain Platforms  
Table 2.2: Existing E-Voting Systems Feature Comparison  
Table 2.3: Research Gap Analysis  
Table 3.1: Functional Requirements Summary  
Table 3.2: Non-Functional Requirements  
Table 3.3: Software Requirements  
Table 3.4: Hardware Requirements  
Table 3.5: Firestore Collections Overview  
Table 3.6: Technology Stack Comparison  
Table 3.7: Development Sprint Schedule  
Table 3.8: Test Case Summary  
Table 3.9: Performance Benchmarks  
Table 3.10: Feature Completion Status

---

## Abbreviations and Acronyms

**AES** - Advanced Encryption Standard  
**API** - Application Programming Interface  
**BaaS** - Backend as a Service  
**DApp** - Decentralized Application  
**EVM** - Ethereum Virtual Machine  
**FCM** - Firebase Cloud Messaging  
**HTTPS** - Hypertext Transfer Protocol Secure  
**JWT** - JSON Web Token  
**KYC** - Know Your Customer  
**MVVM** - Model-View-ViewModel  
**NoSQL** - Not Only SQL  
**OTP** - One-Time Password  
**REST** - Representational State Transfer  
**SDK** - Software Development Kit  
**SHA** - Secure Hash Algorithm  
**UI/UX** - User Interface / User Experience  
**2FA** - Two-Factor Authentication

---
