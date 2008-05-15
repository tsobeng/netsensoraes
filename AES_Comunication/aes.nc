includes aes;

interface AES {

  command void aes_enc( aes_context *ctx, unsigned char *key, int keysize );
  command void aes_dec( aes_context *ctx, unsigned char *key, int keysize );

}
