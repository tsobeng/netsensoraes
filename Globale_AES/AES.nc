includes aes;

interface AES {



  command unsigned char getSBoxValue(unsigned char num);
  command unsigned char getSBoxInvert(unsigned char num);
  command void rotate(unsigned char *word);
  command unsigned char getRconValue(unsigned char num);
  command void core(unsigned char *word, int iteration);
  command void expandKey(unsigned char *expandedKey, unsigned char *key, int size, size_t expandedKeySize);
  /* AES ENCRYPT */
  command void subBytes(unsigned char *state);
  command void shiftRow(unsigned char *state, unsigned char nbr);
  command void shiftRows(unsigned char *state);
  command void addRoundKey(unsigned char *state, unsigned char *roundKey);
  command unsigned char galois_multiplication(unsigned char a, unsigned char b);
  command void mixColumn(unsigned char *column);
  command void mixColumns(unsigned char *state);
  command void aes_round(unsigned char *state, unsigned char *roundKey);
  command void createRoundKey(unsigned char *expandedKey, unsigned char *roundKey);
  command void aes_main(unsigned char *state, unsigned char *expandedKey, int nbrRounds);
  command char aes_encrypt(unsigned char *input, unsigned char *output, unsigned char *key, int size);
  /* AES DECRYPT */
  command char aes_decrypt(unsigned char *input, unsigned char *output, unsigned char *key, int size);
  command void aes_invMain(unsigned char *state, unsigned char *expandedKey, int nbrRounds);
  command void aes_invRound(unsigned char *state, unsigned char *roundKey);
  command void invMixColumns(unsigned char *state);
  command void invMixColumn(unsigned char *column);
  command void invShiftRows(unsigned char *state);
  command void invShiftRow(unsigned char *state, unsigned char nbr);
  command void invSubBytes(unsigned char *state);



}
