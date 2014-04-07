
_signal_test:     file format elf32-i386


Disassembly of section .text:

00000000 <custom_sighandler>:
#include "types.h"
#include "user.h"

void custom_sighandler(int signum)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
    printf(1, "User-defined handler called!\n");
   6:	c7 44 24 04 17 08 00 	movl   $0x817,0x4(%esp)
   d:	00 
   e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  15:	e8 36 04 00 00       	call   450 <printf>
    exit();
  1a:	e8 a1 02 00 00       	call   2c0 <exit>

0000001f <main>:
}

int main(void)
{
  1f:	55                   	push   %ebp
  20:	89 e5                	mov    %esp,%ebp
  22:	83 e4 f0             	and    $0xfffffff0,%esp
  25:	83 ec 20             	sub    $0x20,%esp
    int i = signal(SIGSEGV, custom_sighandler);
  28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  2f:	00 
  30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  37:	e8 34 03 00 00       	call   370 <signal>
  3c:	89 44 24 18          	mov    %eax,0x18(%esp)
    int *ptr = &i;
  40:	8d 44 24 18          	lea    0x18(%esp),%eax
  44:	89 44 24 1c          	mov    %eax,0x1c(%esp)
    
    ptr += 50000;
  48:	81 44 24 1c 40 0d 03 	addl   $0x30d40,0x1c(%esp)
  4f:	00 
    printf(1, "%d\n", *ptr);
  50:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  54:	8b 00                	mov    (%eax),%eax
  56:	89 44 24 08          	mov    %eax,0x8(%esp)
  5a:	c7 44 24 04 35 08 00 	movl   $0x835,0x4(%esp)
  61:	00 
  62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  69:	e8 e2 03 00 00       	call   450 <printf>

    exit();
  6e:	e8 4d 02 00 00       	call   2c0 <exit>
  73:	90                   	nop

00000074 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  74:	55                   	push   %ebp
  75:	89 e5                	mov    %esp,%ebp
  77:	57                   	push   %edi
  78:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7c:	8b 55 10             	mov    0x10(%ebp),%edx
  7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  82:	89 cb                	mov    %ecx,%ebx
  84:	89 df                	mov    %ebx,%edi
  86:	89 d1                	mov    %edx,%ecx
  88:	fc                   	cld    
  89:	f3 aa                	rep stos %al,%es:(%edi)
  8b:	89 ca                	mov    %ecx,%edx
  8d:	89 fb                	mov    %edi,%ebx
  8f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  92:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  95:	5b                   	pop    %ebx
  96:	5f                   	pop    %edi
  97:	5d                   	pop    %ebp
  98:	c3                   	ret    

00000099 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  99:	55                   	push   %ebp
  9a:	89 e5                	mov    %esp,%ebp
  9c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  9f:	8b 45 08             	mov    0x8(%ebp),%eax
  a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a5:	90                   	nop
  a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  a9:	8a 10                	mov    (%eax),%dl
  ab:	8b 45 08             	mov    0x8(%ebp),%eax
  ae:	88 10                	mov    %dl,(%eax)
  b0:	8b 45 08             	mov    0x8(%ebp),%eax
  b3:	8a 00                	mov    (%eax),%al
  b5:	84 c0                	test   %al,%al
  b7:	0f 95 c0             	setne  %al
  ba:	ff 45 08             	incl   0x8(%ebp)
  bd:	ff 45 0c             	incl   0xc(%ebp)
  c0:	84 c0                	test   %al,%al
  c2:	75 e2                	jne    a6 <strcpy+0xd>
    ;
  return os;
  c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c7:	c9                   	leave  
  c8:	c3                   	ret    

000000c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c9:	55                   	push   %ebp
  ca:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  cc:	eb 06                	jmp    d4 <strcmp+0xb>
    p++, q++;
  ce:	ff 45 08             	incl   0x8(%ebp)
  d1:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d4:	8b 45 08             	mov    0x8(%ebp),%eax
  d7:	8a 00                	mov    (%eax),%al
  d9:	84 c0                	test   %al,%al
  db:	74 0e                	je     eb <strcmp+0x22>
  dd:	8b 45 08             	mov    0x8(%ebp),%eax
  e0:	8a 10                	mov    (%eax),%dl
  e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  e5:	8a 00                	mov    (%eax),%al
  e7:	38 c2                	cmp    %al,%dl
  e9:	74 e3                	je     ce <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  eb:	8b 45 08             	mov    0x8(%ebp),%eax
  ee:	8a 00                	mov    (%eax),%al
  f0:	0f b6 d0             	movzbl %al,%edx
  f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  f6:	8a 00                	mov    (%eax),%al
  f8:	0f b6 c0             	movzbl %al,%eax
  fb:	89 d1                	mov    %edx,%ecx
  fd:	29 c1                	sub    %eax,%ecx
  ff:	89 c8                	mov    %ecx,%eax
}
 101:	5d                   	pop    %ebp
 102:	c3                   	ret    

00000103 <strlen>:

uint
strlen(char *s)
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 109:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 110:	eb 03                	jmp    115 <strlen+0x12>
 112:	ff 45 fc             	incl   -0x4(%ebp)
 115:	8b 55 fc             	mov    -0x4(%ebp),%edx
 118:	8b 45 08             	mov    0x8(%ebp),%eax
 11b:	01 d0                	add    %edx,%eax
 11d:	8a 00                	mov    (%eax),%al
 11f:	84 c0                	test   %al,%al
 121:	75 ef                	jne    112 <strlen+0xf>
    ;
  return n;
 123:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 126:	c9                   	leave  
 127:	c3                   	ret    

00000128 <memset>:

void*
memset(void *dst, int c, uint n)
{
 128:	55                   	push   %ebp
 129:	89 e5                	mov    %esp,%ebp
 12b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 12e:	8b 45 10             	mov    0x10(%ebp),%eax
 131:	89 44 24 08          	mov    %eax,0x8(%esp)
 135:	8b 45 0c             	mov    0xc(%ebp),%eax
 138:	89 44 24 04          	mov    %eax,0x4(%esp)
 13c:	8b 45 08             	mov    0x8(%ebp),%eax
 13f:	89 04 24             	mov    %eax,(%esp)
 142:	e8 2d ff ff ff       	call   74 <stosb>
  return dst;
 147:	8b 45 08             	mov    0x8(%ebp),%eax
}
 14a:	c9                   	leave  
 14b:	c3                   	ret    

0000014c <strchr>:

char*
strchr(const char *s, char c)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	83 ec 04             	sub    $0x4,%esp
 152:	8b 45 0c             	mov    0xc(%ebp),%eax
 155:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 158:	eb 12                	jmp    16c <strchr+0x20>
    if(*s == c)
 15a:	8b 45 08             	mov    0x8(%ebp),%eax
 15d:	8a 00                	mov    (%eax),%al
 15f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 162:	75 05                	jne    169 <strchr+0x1d>
      return (char*)s;
 164:	8b 45 08             	mov    0x8(%ebp),%eax
 167:	eb 11                	jmp    17a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 169:	ff 45 08             	incl   0x8(%ebp)
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	8a 00                	mov    (%eax),%al
 171:	84 c0                	test   %al,%al
 173:	75 e5                	jne    15a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 175:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17a:	c9                   	leave  
 17b:	c3                   	ret    

0000017c <gets>:

char*
gets(char *buf, int max)
{
 17c:	55                   	push   %ebp
 17d:	89 e5                	mov    %esp,%ebp
 17f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 182:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 189:	eb 42                	jmp    1cd <gets+0x51>
    cc = read(0, &c, 1);
 18b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 192:	00 
 193:	8d 45 ef             	lea    -0x11(%ebp),%eax
 196:	89 44 24 04          	mov    %eax,0x4(%esp)
 19a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 1a1:	e8 32 01 00 00       	call   2d8 <read>
 1a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ad:	7e 29                	jle    1d8 <gets+0x5c>
      break;
    buf[i++] = c;
 1af:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1b2:	8b 45 08             	mov    0x8(%ebp),%eax
 1b5:	01 c2                	add    %eax,%edx
 1b7:	8a 45 ef             	mov    -0x11(%ebp),%al
 1ba:	88 02                	mov    %al,(%edx)
 1bc:	ff 45 f4             	incl   -0xc(%ebp)
    if(c == '\n' || c == '\r')
 1bf:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c2:	3c 0a                	cmp    $0xa,%al
 1c4:	74 13                	je     1d9 <gets+0x5d>
 1c6:	8a 45 ef             	mov    -0x11(%ebp),%al
 1c9:	3c 0d                	cmp    $0xd,%al
 1cb:	74 0c                	je     1d9 <gets+0x5d>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d0:	40                   	inc    %eax
 1d1:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1d4:	7c b5                	jl     18b <gets+0xf>
 1d6:	eb 01                	jmp    1d9 <gets+0x5d>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1d8:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	01 d0                	add    %edx,%eax
 1e1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <stat>:

int
stat(char *n, struct stat *st)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
 1ec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1f6:	00 
 1f7:	8b 45 08             	mov    0x8(%ebp),%eax
 1fa:	89 04 24             	mov    %eax,(%esp)
 1fd:	e8 fe 00 00 00       	call   300 <open>
 202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 209:	79 07                	jns    212 <stat+0x29>
    return -1;
 20b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 210:	eb 23                	jmp    235 <stat+0x4c>
  r = fstat(fd, st);
 212:	8b 45 0c             	mov    0xc(%ebp),%eax
 215:	89 44 24 04          	mov    %eax,0x4(%esp)
 219:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21c:	89 04 24             	mov    %eax,(%esp)
 21f:	e8 f4 00 00 00       	call   318 <fstat>
 224:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 227:	8b 45 f4             	mov    -0xc(%ebp),%eax
 22a:	89 04 24             	mov    %eax,(%esp)
 22d:	e8 b6 00 00 00       	call   2e8 <close>
  return r;
 232:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 235:	c9                   	leave  
 236:	c3                   	ret    

00000237 <atoi>:

int
atoi(const char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 244:	eb 21                	jmp    267 <atoi+0x30>
    n = n*10 + *s++ - '0';
 246:	8b 55 fc             	mov    -0x4(%ebp),%edx
 249:	89 d0                	mov    %edx,%eax
 24b:	c1 e0 02             	shl    $0x2,%eax
 24e:	01 d0                	add    %edx,%eax
 250:	d1 e0                	shl    %eax
 252:	89 c2                	mov    %eax,%edx
 254:	8b 45 08             	mov    0x8(%ebp),%eax
 257:	8a 00                	mov    (%eax),%al
 259:	0f be c0             	movsbl %al,%eax
 25c:	01 d0                	add    %edx,%eax
 25e:	83 e8 30             	sub    $0x30,%eax
 261:	89 45 fc             	mov    %eax,-0x4(%ebp)
 264:	ff 45 08             	incl   0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 267:	8b 45 08             	mov    0x8(%ebp),%eax
 26a:	8a 00                	mov    (%eax),%al
 26c:	3c 2f                	cmp    $0x2f,%al
 26e:	7e 09                	jle    279 <atoi+0x42>
 270:	8b 45 08             	mov    0x8(%ebp),%eax
 273:	8a 00                	mov    (%eax),%al
 275:	3c 39                	cmp    $0x39,%al
 277:	7e cd                	jle    246 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 279:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 27c:	c9                   	leave  
 27d:	c3                   	ret    

0000027e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 284:	8b 45 08             	mov    0x8(%ebp),%eax
 287:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 28a:	8b 45 0c             	mov    0xc(%ebp),%eax
 28d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 290:	eb 10                	jmp    2a2 <memmove+0x24>
    *dst++ = *src++;
 292:	8b 45 f8             	mov    -0x8(%ebp),%eax
 295:	8a 10                	mov    (%eax),%dl
 297:	8b 45 fc             	mov    -0x4(%ebp),%eax
 29a:	88 10                	mov    %dl,(%eax)
 29c:	ff 45 fc             	incl   -0x4(%ebp)
 29f:	ff 45 f8             	incl   -0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 2a6:	0f 9f c0             	setg   %al
 2a9:	ff 4d 10             	decl   0x10(%ebp)
 2ac:	84 c0                	test   %al,%al
 2ae:	75 e2                	jne    292 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2b0:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    
 2b5:	66 90                	xchg   %ax,%ax
 2b7:	90                   	nop

000002b8 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b8:	b8 01 00 00 00       	mov    $0x1,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <exit>:
SYSCALL(exit)
 2c0:	b8 02 00 00 00       	mov    $0x2,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <wait>:
SYSCALL(wait)
 2c8:	b8 03 00 00 00       	mov    $0x3,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <pipe>:
SYSCALL(pipe)
 2d0:	b8 04 00 00 00       	mov    $0x4,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <read>:
SYSCALL(read)
 2d8:	b8 05 00 00 00       	mov    $0x5,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <write>:
SYSCALL(write)
 2e0:	b8 10 00 00 00       	mov    $0x10,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <close>:
SYSCALL(close)
 2e8:	b8 15 00 00 00       	mov    $0x15,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <kill>:
SYSCALL(kill)
 2f0:	b8 06 00 00 00       	mov    $0x6,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <exec>:
SYSCALL(exec)
 2f8:	b8 07 00 00 00       	mov    $0x7,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <open>:
SYSCALL(open)
 300:	b8 0f 00 00 00       	mov    $0xf,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <mknod>:
SYSCALL(mknod)
 308:	b8 11 00 00 00       	mov    $0x11,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <unlink>:
SYSCALL(unlink)
 310:	b8 12 00 00 00       	mov    $0x12,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <fstat>:
SYSCALL(fstat)
 318:	b8 08 00 00 00       	mov    $0x8,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <link>:
SYSCALL(link)
 320:	b8 13 00 00 00       	mov    $0x13,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <mkdir>:
SYSCALL(mkdir)
 328:	b8 14 00 00 00       	mov    $0x14,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <chdir>:
SYSCALL(chdir)
 330:	b8 09 00 00 00       	mov    $0x9,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <dup>:
SYSCALL(dup)
 338:	b8 0a 00 00 00       	mov    $0xa,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <getpid>:
SYSCALL(getpid)
 340:	b8 0b 00 00 00       	mov    $0xb,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <sbrk>:
SYSCALL(sbrk)
 348:	b8 0c 00 00 00       	mov    $0xc,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <sleep>:
SYSCALL(sleep)
 350:	b8 0d 00 00 00       	mov    $0xd,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <uptime>:
SYSCALL(uptime)
 358:	b8 0e 00 00 00       	mov    $0xe,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <getppid>:
SYSCALL(getppid)        // USER DEFINED SYS CALL
 360:	b8 16 00 00 00       	mov    $0x16,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <icount>:
SYSCALL(icount)         // USER DEFINED SYS CALL
 368:	b8 17 00 00 00       	mov    $0x17,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <signal>:
SYSCALL(signal)         // USER DEFINED SYS CALL
 370:	b8 18 00 00 00       	mov    $0x18,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 378:	55                   	push   %ebp
 379:	89 e5                	mov    %esp,%ebp
 37b:	83 ec 28             	sub    $0x28,%esp
 37e:	8b 45 0c             	mov    0xc(%ebp),%eax
 381:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 384:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 38b:	00 
 38c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 38f:	89 44 24 04          	mov    %eax,0x4(%esp)
 393:	8b 45 08             	mov    0x8(%ebp),%eax
 396:	89 04 24             	mov    %eax,(%esp)
 399:	e8 42 ff ff ff       	call   2e0 <write>
}
 39e:	c9                   	leave  
 39f:	c3                   	ret    

000003a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a0:	55                   	push   %ebp
 3a1:	89 e5                	mov    %esp,%ebp
 3a3:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3ad:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3b1:	74 17                	je     3ca <printint+0x2a>
 3b3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3b7:	79 11                	jns    3ca <printint+0x2a>
    neg = 1;
 3b9:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c3:	f7 d8                	neg    %eax
 3c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3c8:	eb 06                	jmp    3d0 <printint+0x30>
  } else {
    x = xx;
 3ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3dd:	ba 00 00 00 00       	mov    $0x0,%edx
 3e2:	f7 f1                	div    %ecx
 3e4:	89 d0                	mov    %edx,%eax
 3e6:	8a 80 98 0a 00 00    	mov    0xa98(%eax),%al
 3ec:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 3ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3f2:	01 ca                	add    %ecx,%edx
 3f4:	88 02                	mov    %al,(%edx)
 3f6:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
 3f9:	8b 55 10             	mov    0x10(%ebp),%edx
 3fc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
 402:	ba 00 00 00 00       	mov    $0x0,%edx
 407:	f7 75 d4             	divl   -0x2c(%ebp)
 40a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 40d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 411:	75 c4                	jne    3d7 <printint+0x37>
  if(neg)
 413:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 417:	74 2c                	je     445 <printint+0xa5>
    buf[i++] = '-';
 419:	8d 55 dc             	lea    -0x24(%ebp),%edx
 41c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 41f:	01 d0                	add    %edx,%eax
 421:	c6 00 2d             	movb   $0x2d,(%eax)
 424:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
 427:	eb 1c                	jmp    445 <printint+0xa5>
    putc(fd, buf[i]);
 429:	8d 55 dc             	lea    -0x24(%ebp),%edx
 42c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42f:	01 d0                	add    %edx,%eax
 431:	8a 00                	mov    (%eax),%al
 433:	0f be c0             	movsbl %al,%eax
 436:	89 44 24 04          	mov    %eax,0x4(%esp)
 43a:	8b 45 08             	mov    0x8(%ebp),%eax
 43d:	89 04 24             	mov    %eax,(%esp)
 440:	e8 33 ff ff ff       	call   378 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 445:	ff 4d f4             	decl   -0xc(%ebp)
 448:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 44c:	79 db                	jns    429 <printint+0x89>
    putc(fd, buf[i]);
}
 44e:	c9                   	leave  
 44f:	c3                   	ret    

00000450 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 456:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 45d:	8d 45 0c             	lea    0xc(%ebp),%eax
 460:	83 c0 04             	add    $0x4,%eax
 463:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 466:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 46d:	e9 78 01 00 00       	jmp    5ea <printf+0x19a>
    c = fmt[i] & 0xff;
 472:	8b 55 0c             	mov    0xc(%ebp),%edx
 475:	8b 45 f0             	mov    -0x10(%ebp),%eax
 478:	01 d0                	add    %edx,%eax
 47a:	8a 00                	mov    (%eax),%al
 47c:	0f be c0             	movsbl %al,%eax
 47f:	25 ff 00 00 00       	and    $0xff,%eax
 484:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 487:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 48b:	75 2c                	jne    4b9 <printf+0x69>
      if(c == '%'){
 48d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 491:	75 0c                	jne    49f <printf+0x4f>
        state = '%';
 493:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 49a:	e9 48 01 00 00       	jmp    5e7 <printf+0x197>
      } else {
        putc(fd, c);
 49f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4a2:	0f be c0             	movsbl %al,%eax
 4a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4a9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ac:	89 04 24             	mov    %eax,(%esp)
 4af:	e8 c4 fe ff ff       	call   378 <putc>
 4b4:	e9 2e 01 00 00       	jmp    5e7 <printf+0x197>
      }
    } else if(state == '%'){
 4b9:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4bd:	0f 85 24 01 00 00    	jne    5e7 <printf+0x197>
      if(c == 'd'){
 4c3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4c7:	75 2d                	jne    4f6 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 4c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4cc:	8b 00                	mov    (%eax),%eax
 4ce:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 4d5:	00 
 4d6:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 4dd:	00 
 4de:	89 44 24 04          	mov    %eax,0x4(%esp)
 4e2:	8b 45 08             	mov    0x8(%ebp),%eax
 4e5:	89 04 24             	mov    %eax,(%esp)
 4e8:	e8 b3 fe ff ff       	call   3a0 <printint>
        ap++;
 4ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f1:	e9 ea 00 00 00       	jmp    5e0 <printf+0x190>
      } else if(c == 'x' || c == 'p'){
 4f6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4fa:	74 06                	je     502 <printf+0xb2>
 4fc:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 500:	75 2d                	jne    52f <printf+0xdf>
        printint(fd, *ap, 16, 0);
 502:	8b 45 e8             	mov    -0x18(%ebp),%eax
 505:	8b 00                	mov    (%eax),%eax
 507:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 50e:	00 
 50f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 516:	00 
 517:	89 44 24 04          	mov    %eax,0x4(%esp)
 51b:	8b 45 08             	mov    0x8(%ebp),%eax
 51e:	89 04 24             	mov    %eax,(%esp)
 521:	e8 7a fe ff ff       	call   3a0 <printint>
        ap++;
 526:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52a:	e9 b1 00 00 00       	jmp    5e0 <printf+0x190>
      } else if(c == 's'){
 52f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 533:	75 43                	jne    578 <printf+0x128>
        s = (char*)*ap;
 535:	8b 45 e8             	mov    -0x18(%ebp),%eax
 538:	8b 00                	mov    (%eax),%eax
 53a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 53d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 541:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 545:	75 25                	jne    56c <printf+0x11c>
          s = "(null)";
 547:	c7 45 f4 39 08 00 00 	movl   $0x839,-0xc(%ebp)
        while(*s != 0){
 54e:	eb 1c                	jmp    56c <printf+0x11c>
          putc(fd, *s);
 550:	8b 45 f4             	mov    -0xc(%ebp),%eax
 553:	8a 00                	mov    (%eax),%al
 555:	0f be c0             	movsbl %al,%eax
 558:	89 44 24 04          	mov    %eax,0x4(%esp)
 55c:	8b 45 08             	mov    0x8(%ebp),%eax
 55f:	89 04 24             	mov    %eax,(%esp)
 562:	e8 11 fe ff ff       	call   378 <putc>
          s++;
 567:	ff 45 f4             	incl   -0xc(%ebp)
 56a:	eb 01                	jmp    56d <printf+0x11d>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 56c:	90                   	nop
 56d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 570:	8a 00                	mov    (%eax),%al
 572:	84 c0                	test   %al,%al
 574:	75 da                	jne    550 <printf+0x100>
 576:	eb 68                	jmp    5e0 <printf+0x190>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 578:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 57c:	75 1d                	jne    59b <printf+0x14b>
        putc(fd, *ap);
 57e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 581:	8b 00                	mov    (%eax),%eax
 583:	0f be c0             	movsbl %al,%eax
 586:	89 44 24 04          	mov    %eax,0x4(%esp)
 58a:	8b 45 08             	mov    0x8(%ebp),%eax
 58d:	89 04 24             	mov    %eax,(%esp)
 590:	e8 e3 fd ff ff       	call   378 <putc>
        ap++;
 595:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 599:	eb 45                	jmp    5e0 <printf+0x190>
      } else if(c == '%'){
 59b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 59f:	75 17                	jne    5b8 <printf+0x168>
        putc(fd, c);
 5a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a4:	0f be c0             	movsbl %al,%eax
 5a7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ab:	8b 45 08             	mov    0x8(%ebp),%eax
 5ae:	89 04 24             	mov    %eax,(%esp)
 5b1:	e8 c2 fd ff ff       	call   378 <putc>
 5b6:	eb 28                	jmp    5e0 <printf+0x190>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b8:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 5bf:	00 
 5c0:	8b 45 08             	mov    0x8(%ebp),%eax
 5c3:	89 04 24             	mov    %eax,(%esp)
 5c6:	e8 ad fd ff ff       	call   378 <putc>
        putc(fd, c);
 5cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ce:	0f be c0             	movsbl %al,%eax
 5d1:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	89 04 24             	mov    %eax,(%esp)
 5db:	e8 98 fd ff ff       	call   378 <putc>
      }
      state = 0;
 5e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5e7:	ff 45 f0             	incl   -0x10(%ebp)
 5ea:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f0:	01 d0                	add    %edx,%eax
 5f2:	8a 00                	mov    (%eax),%al
 5f4:	84 c0                	test   %al,%al
 5f6:	0f 85 76 fe ff ff    	jne    472 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5fc:	c9                   	leave  
 5fd:	c3                   	ret    
 5fe:	66 90                	xchg   %ax,%ax

00000600 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 600:	55                   	push   %ebp
 601:	89 e5                	mov    %esp,%ebp
 603:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 606:	8b 45 08             	mov    0x8(%ebp),%eax
 609:	83 e8 08             	sub    $0x8,%eax
 60c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60f:	a1 b4 0a 00 00       	mov    0xab4,%eax
 614:	89 45 fc             	mov    %eax,-0x4(%ebp)
 617:	eb 24                	jmp    63d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 619:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61c:	8b 00                	mov    (%eax),%eax
 61e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 621:	77 12                	ja     635 <free+0x35>
 623:	8b 45 f8             	mov    -0x8(%ebp),%eax
 626:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 629:	77 24                	ja     64f <free+0x4f>
 62b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62e:	8b 00                	mov    (%eax),%eax
 630:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 633:	77 1a                	ja     64f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 635:	8b 45 fc             	mov    -0x4(%ebp),%eax
 638:	8b 00                	mov    (%eax),%eax
 63a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 640:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 643:	76 d4                	jbe    619 <free+0x19>
 645:	8b 45 fc             	mov    -0x4(%ebp),%eax
 648:	8b 00                	mov    (%eax),%eax
 64a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 64d:	76 ca                	jbe    619 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 64f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 652:	8b 40 04             	mov    0x4(%eax),%eax
 655:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 65c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65f:	01 c2                	add    %eax,%edx
 661:	8b 45 fc             	mov    -0x4(%ebp),%eax
 664:	8b 00                	mov    (%eax),%eax
 666:	39 c2                	cmp    %eax,%edx
 668:	75 24                	jne    68e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 66a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66d:	8b 50 04             	mov    0x4(%eax),%edx
 670:	8b 45 fc             	mov    -0x4(%ebp),%eax
 673:	8b 00                	mov    (%eax),%eax
 675:	8b 40 04             	mov    0x4(%eax),%eax
 678:	01 c2                	add    %eax,%edx
 67a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	8b 00                	mov    (%eax),%eax
 685:	8b 10                	mov    (%eax),%edx
 687:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68a:	89 10                	mov    %edx,(%eax)
 68c:	eb 0a                	jmp    698 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 68e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 691:	8b 10                	mov    (%eax),%edx
 693:	8b 45 f8             	mov    -0x8(%ebp),%eax
 696:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 698:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69b:	8b 40 04             	mov    0x4(%eax),%eax
 69e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a8:	01 d0                	add    %edx,%eax
 6aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ad:	75 20                	jne    6cf <free+0xcf>
    p->s.size += bp->s.size;
 6af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b2:	8b 50 04             	mov    0x4(%eax),%edx
 6b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b8:	8b 40 04             	mov    0x4(%eax),%eax
 6bb:	01 c2                	add    %eax,%edx
 6bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c6:	8b 10                	mov    (%eax),%edx
 6c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6cb:	89 10                	mov    %edx,(%eax)
 6cd:	eb 08                	jmp    6d7 <free+0xd7>
  } else
    p->s.ptr = bp;
 6cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d5:	89 10                	mov    %edx,(%eax)
  freep = p;
 6d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6da:	a3 b4 0a 00 00       	mov    %eax,0xab4
}
 6df:	c9                   	leave  
 6e0:	c3                   	ret    

000006e1 <morecore>:

static Header*
morecore(uint nu)
{
 6e1:	55                   	push   %ebp
 6e2:	89 e5                	mov    %esp,%ebp
 6e4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6e7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ee:	77 07                	ja     6f7 <morecore+0x16>
    nu = 4096;
 6f0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6f7:	8b 45 08             	mov    0x8(%ebp),%eax
 6fa:	c1 e0 03             	shl    $0x3,%eax
 6fd:	89 04 24             	mov    %eax,(%esp)
 700:	e8 43 fc ff ff       	call   348 <sbrk>
 705:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 708:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 70c:	75 07                	jne    715 <morecore+0x34>
    return 0;
 70e:	b8 00 00 00 00       	mov    $0x0,%eax
 713:	eb 22                	jmp    737 <morecore+0x56>
  hp = (Header*)p;
 715:	8b 45 f4             	mov    -0xc(%ebp),%eax
 718:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 71b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71e:	8b 55 08             	mov    0x8(%ebp),%edx
 721:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 724:	8b 45 f0             	mov    -0x10(%ebp),%eax
 727:	83 c0 08             	add    $0x8,%eax
 72a:	89 04 24             	mov    %eax,(%esp)
 72d:	e8 ce fe ff ff       	call   600 <free>
  return freep;
 732:	a1 b4 0a 00 00       	mov    0xab4,%eax
}
 737:	c9                   	leave  
 738:	c3                   	ret    

00000739 <malloc>:

void*
malloc(uint nbytes)
{
 739:	55                   	push   %ebp
 73a:	89 e5                	mov    %esp,%ebp
 73c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	83 c0 07             	add    $0x7,%eax
 745:	c1 e8 03             	shr    $0x3,%eax
 748:	40                   	inc    %eax
 749:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 74c:	a1 b4 0a 00 00       	mov    0xab4,%eax
 751:	89 45 f0             	mov    %eax,-0x10(%ebp)
 754:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 758:	75 23                	jne    77d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 75a:	c7 45 f0 ac 0a 00 00 	movl   $0xaac,-0x10(%ebp)
 761:	8b 45 f0             	mov    -0x10(%ebp),%eax
 764:	a3 b4 0a 00 00       	mov    %eax,0xab4
 769:	a1 b4 0a 00 00       	mov    0xab4,%eax
 76e:	a3 ac 0a 00 00       	mov    %eax,0xaac
    base.s.size = 0;
 773:	c7 05 b0 0a 00 00 00 	movl   $0x0,0xab0
 77a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 780:	8b 00                	mov    (%eax),%eax
 782:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	8b 40 04             	mov    0x4(%eax),%eax
 78b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 78e:	72 4d                	jb     7dd <malloc+0xa4>
      if(p->s.size == nunits)
 790:	8b 45 f4             	mov    -0xc(%ebp),%eax
 793:	8b 40 04             	mov    0x4(%eax),%eax
 796:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 799:	75 0c                	jne    7a7 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 79b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79e:	8b 10                	mov    (%eax),%edx
 7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a3:	89 10                	mov    %edx,(%eax)
 7a5:	eb 26                	jmp    7cd <malloc+0x94>
      else {
        p->s.size -= nunits;
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	8b 40 04             	mov    0x4(%eax),%eax
 7ad:	89 c2                	mov    %eax,%edx
 7af:	2b 55 ec             	sub    -0x14(%ebp),%edx
 7b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	8b 40 04             	mov    0x4(%eax),%eax
 7be:	c1 e0 03             	shl    $0x3,%eax
 7c1:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7ca:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d0:	a3 b4 0a 00 00       	mov    %eax,0xab4
      return (void*)(p + 1);
 7d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d8:	83 c0 08             	add    $0x8,%eax
 7db:	eb 38                	jmp    815 <malloc+0xdc>
    }
    if(p == freep)
 7dd:	a1 b4 0a 00 00       	mov    0xab4,%eax
 7e2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e5:	75 1b                	jne    802 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 7e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7ea:	89 04 24             	mov    %eax,(%esp)
 7ed:	e8 ef fe ff ff       	call   6e1 <morecore>
 7f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7f9:	75 07                	jne    802 <malloc+0xc9>
        return 0;
 7fb:	b8 00 00 00 00       	mov    $0x0,%eax
 800:	eb 13                	jmp    815 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	8b 45 f4             	mov    -0xc(%ebp),%eax
 805:	89 45 f0             	mov    %eax,-0x10(%ebp)
 808:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80b:	8b 00                	mov    (%eax),%eax
 80d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 810:	e9 70 ff ff ff       	jmp    785 <malloc+0x4c>
}
 815:	c9                   	leave  
 816:	c3                   	ret    
