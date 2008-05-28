includes aes;

interface AES {

  command void aes_set_key_enc( aes_context *ctx, unsigned char *key, int keysize);
  command void aes_set_key_dec( aes_context *ctx, unsigned char *key, int keysize);
  command void aes_enc( aes_context *ctx, unsigned char input[16], unsigned char output[16]);
  command void aes_dec( aes_context *ctx, unsigned char input[16], unsigned char output[16]);

}
