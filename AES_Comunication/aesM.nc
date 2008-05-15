
includes aes;

module AESM {
  provides interface AES;
}

implementation {

	 command void AES.aes_enc( aes_context *ctx, unsigned char *key, int keysize ){
	 	dbg("aes","AES.aes_enc");
	 }
	 
 	 command void AES.aes_dec( aes_context *ctx, unsigned char *key, int keysize ){
 	 	dbg("aes","AES.aes_dec");
 	 }
 
}
