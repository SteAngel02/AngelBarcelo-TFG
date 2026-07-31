import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/auth_repository.dart';
import '../domain/user_entity.dart';
import 'user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Instancias de Firebase (Singletons)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    // Transformamos el Stream de User de Firebase a nuestro UserEntity
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      // Si hay un usuario, buscamos sus datos adicionales en Firestore
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final doc = await _db
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String userName,
  }) async {
    try {
      // 1. Crear el usuario en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // 2. Crear el objeto UserModel inicial
        final newUser = UserModel(
          id: credential.user!.uid,
          userName: userName,
          email: email,
          activeAvatarId: null,
          graveyard: [],
        );

        // 3. Guardar en Firestore
        await _db
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toFirestore());

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        userName: user.userName,
        email: user.email,
        activeAvatarId: user.activeAvatarId,
        graveyard: user.graveyard,
      );
      await _db.collection('users').doc(user.id).update(userModel.toFirestore());
    } catch (e) {
      rethrow;
    }
  }
}
