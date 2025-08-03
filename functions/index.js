const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotificationOnNewMessage = functions.firestore
  .document("chat_rooms/{chatRoomID}/messages/{messageID}")
  .onCreate(async (snap, context) => {
    const messageData = snap.data();

    const {
      senderID,
      senderEmail,
      receiverID,
      receiverEmail,
      message
    } = messageData;

    const userDoc = await admin.firestore().collection('users').doc(receiverID).get();
    const userData = userDoc.data();

    if (!userData || !userData.fcmToken) {
      console.log("❌ No FCM token found for receiver:", receiverID);
      return null;
    }

    const fcmToken = userData.fcmToken;

    const payload = {
      notification: {
        title: "New Message 💬",
        body: message,
      },
      data: {
        receiverID: receiverID,
        receiverEmail: receiverEmail,
        receiverName: userData.Name || '',
        receiverImage: userData.Photo || ''
      },
    };

    try {
      const response = await admin.messaging().sendToDevice(fcmToken, payload);
      console.log("✅ Notification sent:", response);
    } catch (error) {
      console.error("❌ Error sending notification:", error);
    }
  });
