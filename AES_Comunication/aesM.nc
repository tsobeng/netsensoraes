
includes aes;

module AESM {
  provides interface AES;
}

implementation {

	 command void AES.aes_enc( aes_context *ctx, unsigned char *key, int keysize ){
		ctx->buf[0]=ctx->buf[0]+10;
	 	dbg("aes","AES.aes_enc\n");
	 }
	 
 	 command void AES.aes_dec( aes_context *ctx, unsigned char *key, int keysize ){
		ctx->buf[0]=ctx->buf[0]-10;
 	 	dbg("aes","AES.aes_dec\n");
 	 }
 
}
