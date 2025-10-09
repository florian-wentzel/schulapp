enum ConflictResolutionStrategy {
  //z.B. Wenn server neuere Version hat auch dann diese nehmen
  lastWriteWins,
  throwOnConflict,
  // //z.B. neues TodoEvent erstellen mit (remote)
  // //keepBoth
  // dublicate,
  // //Pop up welches verwendet werden soll
  // manual,
}
