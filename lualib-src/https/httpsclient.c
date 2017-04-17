/*File:client.c
 *Auth:sjin
 *Date��2014-03-11
 *
 */


#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <resolv.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "openssl/ssl.h"
#include "openssl/err.h"

#define MAXBUF 1024

// void ShowCerts(SSL * ssl)
// {
  // X509 *cert;
  // char *line;

  // cert = SSL_get_peer_certificate(ssl);
  // if (cert != NULL) {
    // printf("Digital certificate information:\n");
    // line = X509_NAME_oneline(X509_get_subject_name(cert), 0, 0);
    // printf("Certificate: %s\n", line);
    // free(line);
    // line = X509_NAME_oneline(X509_get_issuer_name(cert), 0, 0);
    // printf("Issuer: %s\n", line);
    // free(line);
    // X509_free(cert);
  // }
  // else
    // printf("No certificate information��\n");
// }

int main(int argc, char **argv)
{
  int sockfd, len;
  char sendFN[1024];
  struct sockaddr_in dest;
  char buffer[MAXBUF + 1];
  SSL_CTX *ctx;
  SSL *ssl;
  char host_file[] = "";
  char  host_addr[] = "www.jd.com";
  char ip[] = "112.91.125.129";
  int port = "443";
 

  /* SSL ���ʼ�� */
  SSL_library_init();
  OpenSSL_add_all_algorithms();
  SSL_load_error_strings();
  ctx = SSL_CTX_new(SSLv23_client_method());
  if (ctx == NULL)
  {
    ERR_print_errors_fp(stdout);
    exit(1);
  }

  /* ����һ�� socket ���� tcp ͨ�� */
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    perror("Socket");
    exit(errno);
  }
  printf("socket created\n");

  /* ��ʼ���������ˣ��Է����ĵ�ַ�Ͷ˿���Ϣ */
  bzero(&dest, sizeof(dest));
  dest.sin_family = AF_INET;
  dest.sin_port = htons(atoi(port));
  if (inet_aton(ip, (struct in_addr *) &dest.sin_addr.s_addr) == 0)
  {
    perror(ip);
    exit(errno);
  }
  printf("address created\n");

  /* ���ӷ����� */
  if (connect(sockfd, (struct sockaddr *) &dest, sizeof(dest)) != 0)
  {
    perror("Connect ");
    exit(errno);
  }
  printf("server connected\n\n");

  /* ���� ctx ����һ���µ� SSL */
  ssl = SSL_new(ctx);
  SSL_set_fd(ssl, sockfd);
  /* ���� SSL ���� */
  if (SSL_connect(ssl) == -1)
    ERR_print_errors_fp(stderr);
  else
  {
    printf("Connected with %s encryption\n", SSL_get_cipher(ssl));
    // ShowCerts(ssl);
  }

  
  sprintf(sendFN, "GET /%s HTTP/1.1\r\nAccept: */*\r\nAccept-Language: zh-cn\r\n\
User-Agent: Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)\r\n\
Host: %s\r\nConnection: Close\r\n\r\n", host_file, host_addr);
    

  len = SSL_write(ssl, sendFN, strlen(sendFN));
  if (len < 0)
    printf("'%s'message Send failure ��Error code is %d��Error messages are '%s'\n", buffer, errno, strerror(errno));


  printf("Send complete !\n");
  
    bzero(buffer, MAXBUF + 1);
	int nbytes;
   /* ���ӳɹ��ˣ�����https��Ӧ��response */
    while ((nbytes = SSL_read(ssl, buffer, 1)) == 1) {

        printf("%s", buffer);        /*��httpsͷ��Ϣ��ӡ����Ļ�� */
        
    }

  /* �ر����� */
  SSL_shutdown(ssl);
  SSL_free(ssl);
  close(sockfd);
  SSL_CTX_free(ctx);
  return 0;
}
