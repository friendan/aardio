// CSmtp.h: interface for the Smtp class.
//
//////////////////////////////////////////////////////////////////////

#pragma once
#ifndef __CSMTP_H__
#define __CSMTP_H__


#include <vector>
#include <string.h>
#include <assert.h>

#ifdef __linux__
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <sys/ioctl.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <netdb.h>
	#include <errno.h>
	#include <stdio.h>
	#include <iostream>
	#include <unistd.h>

	#include <openssl/ssl.h>

	#define SOCKET_ERROR -1
	#define INVALID_SOCKET -1

#ifndef HAVE__STRNICMP
	#define HAVE__STRNICMP
	#define _strnicmp strncasecmp
#endif

	#define OutputDebugStringA(buf)

	typedef unsigned short WORD;
	typedef int SOCKET;
	typedef struct sockaddr_in SOCKADDR_IN;
	typedef struct hostent* LPHOSTENT;
	typedef struct servent* LPSERVENT;
	typedef struct in_addr* LPIN_ADDR;
	typedef struct sockaddr* LPSOCKADDR;

	#define LINUX
#else
	#include <winsock2.h>
	#include <time.h>
	#pragma comment(lib, "ws2_32.lib")

	//Add "openssl-0.9.8l\inc32" to Additional Include Directories
	#include "openssl\ssl.h"

	#if _MSC_VER < 1400
		#define snprintf _snprintf
	#else
		#define snprintf sprintf_s
	#endif
#endif

#include "md5.h"

#define TIME_IN_SEC		3*60	// how long client will wait for server response in non-blocking mode
#define BUFFER_SIZE		10240	// SendData and RecvData buffers sizes
#define MSG_SIZE_IN_MB	25		// the maximum size of the message with all attachments
#define COUNTER_VALUE	100		// how many times program will try to receive data

const char BOUNDARY_TEXT[] = "__MESSAGE__ID__54yg6f6h6y456345";

enum CSmptXPriority
{
	XPRIORITY_HIGH = 2,
	XPRIORITY_NORMAL = 3,
	XPRIORITY_LOW = 4
};

class ECSmtp
{
public:
	enum CSmtpError
	{
		CSMTP_NO_ERROR = 0,
		WSA_STARTUP = 100, // WSAGetLastError()
		WSA_VER,
		WSA_SEND,
		WSA_RECV,
		WSA_CONNECT,
		WSA_GETHOSTBY_NAME_ADDR,
		WSA_INVALID_SOCKET,
		WSA_HOSTNAME,
		WSA_IOCTLSOCKET,
		WSA_SELECT,
		BAD_IPV4_ADDR,
		UNDEF_MSG_HEADER = 200,
		UNDEF_MAIL_FROM,
		UNDEF_SUBJECT,
		UNDEF_RECIPIENTS,
		UNDEF_LOGIN,
		UNDEF_PASSWORD,
		BAD_LOGIN_PASSWORD,
		BAD_DIGEST_RESPONSE,
		BAD_SERVER_NAME,
		UNDEF_RECIPIENT_MAIL,
		COMMAND_MAIL_FROM = 300,
		COMMAND_EHLO,
		COMMAND_AUTH_PLAIN,
		COMMAND_AUTH_LOGIN,
		COMMAND_AUTH_CRAMMD5,
		COMMAND_AUTH_DIGESTMD5,
		COMMAND_DIGESTMD5,
		COMMAND_DATA,
		COMMAND_QUIT,
		COMMAND_RCPT_TO,
		MSG_BODY_ERROR,
		CONNECTION_CLOSED = 400, // by server
		SERVER_NOT_READY, // remote server
		SERVER_NOT_RESPONDING,
		SELECT_TIMEOUT,
		FILE_NOT_EXIST,
		MSG_TOO_BIG,
		BAD_LOGIN_PASS,
		UNDEF_XYZ_RESPONSE,
		LACK_OF_MEMORY,
		TIME_ERROR,
		RECVBUF_IS_EMPTY,
		SENDBUF_IS_EMPTY,
		OUT_OF_MSG_RANGE,
		COMMAND_EHLO_STARTTLS,
		SSL_PROBLEM,
		COMMAND_DATABLOCK,
		STARTTLS_NOT_SUPPORTED,
		LOGIN_NOT_SUPPORTED
	};
	ECSmtp(CSmtpError err_) : ErrorCode(err_) {}
	CSmtpError GetErrorNum(void) const {return ErrorCode;}
	std::string GetErrorText(void) const;

private:
	CSmtpError ErrorCode;
};

enum SMTP_COMMAND
{
	command_INIT,
	command_EHLO,
	command_AUTHPLAIN,
	command_AUTHLOGIN,
	command_AUTHCRAMMD5,
	command_AUTHDIGESTMD5,
	command_DIGESTMD5,
	command_USER,
	command_PASSWORD,
	command_MAILFROM,
	command_RCPTTO,
	command_DATA,
	command_DATABLOCK,
	command_DATAEND,
	command_QUIT,
	command_STARTTLS
};

// TLS/SSL extension
enum SMTP_SECURITY_TYPE
{
	NO_SECURITY,
	USE_TLS,
	USE_SSL,
	DO_NOT_SET
};

typedef struct tagCommand_Entry
{
	SMTP_COMMAND       command;
	int                send_timeout;	 // 0 means no send is required
	int                recv_timeout;	 // 0 means no recv is required
	int                valid_reply_code; // 0 means no recv is required, so no reply code
	ECSmtp::CSmtpError error;
}Command_Entry;

class CSmtp  
{
public:
	CSmtp();
	 ~CSmtp();

	virtual void AddRecipient(const char *email, const char *name=NULL);
	virtual void AddBCCRecipient(const char *email, const char *name=NULL);
	virtual void AddCCRecipient(const char *email, const char *name=NULL);    
	virtual void AddAttachment(const char *path);   
	virtual void AddMsgLine(const char* text);
	virtual void ClearMessage(); 
	virtual void DelRecipients(void);
	virtual void DelBCCRecipients(void);
	virtual void DelCCRecipients(void);
	virtual void DelAttachments(void);
	virtual void DelMsgLines(void);
	virtual void DelMsgLine(unsigned int line);
	virtual void ModMsgLine(unsigned int line,const char* text);
	virtual unsigned int GetBCCRecipientCount() const;    
	virtual unsigned int GetCCRecipientCount() const;
	virtual unsigned int GetRecipientCount() const;    
	//virtual const char* GetLocalHostIP() const;
	virtual const char* GetLocalHostName();
	virtual const char* GetMsgLineText(unsigned int line) const;
	virtual unsigned int GetMsgLines(void) const;
	virtual const char* GetReplyTo() const;
	virtual const char* GetMailFrom() const;
	virtual const char* GetSenderName() const;
	virtual const char* GetSubject() const;
	virtual const char* GetXMailer() const;
	virtual CSmptXPriority GetXPriority() const;
	
	virtual void SetCharSet(const char *sCharSet);
	virtual void SetLocalHostName(const char *sLocalHostName);
	virtual void SetSubject(const char*);
	virtual void SetSenderName(const char*);
	virtual void SetSenderMail(const char*);
	virtual void SetReplyTo(const char*);
	virtual void SetReadReceipt(BOOL requestReceipt);
	virtual void SetXMailer(const char*);
	virtual void SetLogin(const char*);
	virtual void SetPassword(const char*);
	virtual void SetXPriority(CSmptXPriority);
	virtual void SetSMTPServer(const char* server, const unsigned short port=0, BOOL authenticate=TRUE);
	virtual void SetHTMLFormat(BOOL html){ m_bHTML = html ? true:false;};
	virtual void Send();
	virtual ECSmtp::CSmtpError GetErrorNum(void) const {return m_eLastErrorCode;}
	virtual const char * GetErrorText(void) { m_sLastErrorText = ECSmtp(m_eLastErrorCode).GetErrorText(); return m_sLastErrorText.c_str(); };
	virtual const char * GetLastRequest(void) { if( ! m_sLastResponse.empty() ) return m_sLastRequest.c_str(); else return SendBuf; };
	virtual const char * GetLastResponse(void) { if(! m_sLastResponse.empty() ) return m_sLastResponse.c_str(); else return RecvBuf; };
	virtual int GetLastResponseCode(void) { if( m_iLastResponseCode != 0 )return m_iLastResponseCode; else return m_iResponseCode; };
private:	
	ECSmtp::CSmtpError m_eLastErrorCode;
	std::string m_sLastErrorText;
	std::string m_sLastResponse;
	std::string m_sLastRequest;
	int m_iLastResponseCode;
	int m_iResponseCode;

	std::string m_sLocalHostName;
	std::string m_sMailFrom;
	std::string m_sNameFrom;
	std::string m_sSubject;
	std::string m_sCharSet;
	std::string m_sXMailer;
	std::string m_sReplyTo;
	bool m_bReadReceipt;
	std::string m_sIPAddr;
	std::string m_sLogin;
	std::string m_sPassword;
	std::string m_sSMTPSrvName;
	unsigned short m_iSMTPSrvPort;
	bool m_bAuthenticate;
	CSmptXPriority m_iXPriority;
	char *SendBuf;
	char *RecvBuf;
	
	SOCKET hSocket;
	bool m_bConnected;

	struct Recipient
	{
		std::string Name;
		std::string Mail;
	};

	std::vector<Recipient> Recipients;
	std::vector<Recipient> CCRecipients;
	std::vector<Recipient> BCCRecipients;
	std::vector<std::string> Attachments;
	std::vector<std::string> MsgBody;
 
	bool ConnectRemoteServer(const char* szServer, const unsigned short nPort_=0,
		SMTP_SECURITY_TYPE securityType=DO_NOT_SET,
		BOOL authenticate=TRUE, const char* login=NULL,
		const char* password=NULL);
	void DisconnectRemoteServer();
	void ReceiveData(Command_Entry* pEntry);
	void SendData(Command_Entry* pEntry);
	void FormatHeader(char*);
	int SmtpXYZdigits();
	void SayHello();
	void SayQuit();

// TLS/SSL extension
public:
	virtual SMTP_SECURITY_TYPE GetSecurityType() const
	{ return m_type; }
	virtual void SetSecurityType(SMTP_SECURITY_TYPE type)
	{ m_type = type; }
	bool m_bHTML;

private:
	SMTP_SECURITY_TYPE m_type;
	SSL_CTX*      m_ctx;
	SSL*          m_ssl;

	void ReceiveResponse(Command_Entry* pEntry);
	void InitOpenSSL();
	void OpenSSLConnect();
	void CleanupOpenSSL();
	void ReceiveData_SSL(SSL* ssl, Command_Entry* pEntry);
	void SendData_SSL(SSL* ssl, Command_Entry* pEntry);
	void StartTls();


};


#endif // __CSMTP_H__
