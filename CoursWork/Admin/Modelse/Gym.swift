//
//  Gym.swift
//  CoursWork
//
//  Created by Adrian on 25.11.2025.
//

import Foundation

struct GymUpdateRequest: Codable {
    let name: String
    let address: String
    let halls: [Hall]
}

struct Gym: Codable {
    let id: String
    let name: String
    let address: String
    let halls: [Hall]
}

struct Hall: Codable {
    let name: String
    let capacity: Int
}



//import * as functions from "firebase-functions";
//import * as admin from "firebase-admin";
//import express from "express";
//
//admin.initializeApp();
//const db = admin.firestore();
//
//const getApp = express();
//getApp.use(express.json());
//
//getApp.get("/", async (req, res) => {
//  try {
//    const authHeader = req.headers.authorization;
//    if (!authHeader || !authHeader.startsWith("Bearer ")) {
//      return res.status(401).json({error: "Unauthorized: No token provided"});
//    }
//
//    const idToken = authHeader.split("Bearer ")[1];
//
//    try {
//      await admin.auth().verifyIdToken(idToken);
//    } catch (err) {
//      return res.status(401).json({error: "Unauthorized: Invalid token"});
//    }
//
//    const snapshot = await db.collection("gymSections").get();
//
//    const sections = snapshot.docs
//      .map((doc) => ({
//        id: doc.id,
//        ...(doc.data() as any),
//      }))
//      .filter((section) => (section.quantity ?? 0) > 0);
//
//    return res.status(200).json(sections);
//  } catch (error) {
//    console.error("Error getting GymSections:", error);
//    return res.status(500).json({error: (error as Error).message});
//  }
//});
//export const getGymSections = functions.https.onRequest(getApp);
