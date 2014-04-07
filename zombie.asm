
_zombie:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
  if(fork() > 0)
   9:	e8 5a 02 00 00       	call   268 <fork>
   e:	85 c0                	test   %eax,%eax
  10:	7e 0c                	jle    1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  12:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  19:	e8 e2 02 00 00       	call   300 <sleep>
  exit();
  1e:	e8 4d 02 00 00       	call   270 <exit>
  23:	90                   	nop

00000024 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  24:	55                   	push   %ebp
  25:	89 e5                	mov    %esp,%ebp
  27:	57                   	push   %edi
  28:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2c:	8b 55 10             	mov    0x10(%ebp),%edx
  2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  32:	89 cb                	mov    %ecx,%ebx
  34:	89 df                	mov    %ebx,%edi
  36:	89 d1                	mov    %edx,%ecx
  38:	fc                   	cld    
  39:	f3 aa                	rep stos %al,%es:(%edi)
  3b:	89 ca                	mov    %ecx,%edx
  3d:	89 fb                	mov    %edi,%ebx
  3f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  42:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  45:	5b                   	pop    %ebx
  46:	5f                   	pop    %edi
  47:	5d                   	pop    %ebp
  48:	c3                   	ret    

00000049 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  49:	55                   	push   %ebp
  4a:	89 e5                	mov    %esp,%ebp
  4c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  4f:	8b 45 08             	mov    0x8(%ebp),%eax
  52:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  55:	90                   	nop
  56:	8b 45 0c             	mov    0xc(%ebp),%eax
  59:	8a 10                	mov    (%eax),%dl
  5b:	8b 45 08             	mov    0x8(%ebp),%eax
  5e:	88 10                	mov    %dl,(%eax)
  60:	8b 45 08             	mov    0x8(%ebp),%eax
  63:	8a 00                	mov    (%eax),%al
  65:	84 c0                	test   %al,%al
  67:	0f 95 c0             	setne  %al
  6a:	ff 45 08             	incl   0x8(%ebp)
  6d:	ff 45 0c             	incl   0xc(%ebp)
  70:	84 c0                	test   %al,%al
  72:	75 e2                	jne    56 <strcpy+0xd>
    ;
  return os;
  74:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  77:	c9                   	leave  
  78:	c3                   	ret    

00000079 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  7c:	eb 06                	jmp    84 <strcmp+0xb>
    p++, q++;
  7e:	ff 45 08             	incl   0x8(%ebp)
  81:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  84:	8b 45 08             	mov    0x8(%ebp),%eax
  87:	8a 00                	mov    (%eax),%al
  89:	84 c0                	test   %al,%al
  8b:	74 0e                	je     9b <strcmp+0x22>
  8d:	8b 45 08             	mov    0x8(%ebp),%eax
  90:	8a 10                	mov    (%eax),%dl
  92:	8b 45 0c             	mov    0xc(%ebp),%eax
  95:	8a 00                	mov    (%eax),%al
  97:	38 c2                	cmp    %al,%dl
  99:	74 e3                	je     7e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  9b:	8b 45 08             	mov    0x8(%ebp),%eax
  9e:	8a 00                	mov    (%eax),%al
  a0:	0f b6 d0             	movzbl %al,%edx
  a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  a6:	8a 00                	mov    (%eax),%al
  a8:	0f b6 c0             	movzbl %al,%eax
  ab:	89 d1                	mov    %edx,%ecx
  ad:	29 c1                	sub    %eax,%ecx
  af:	89 c8                	mov    %ecx,%eax
}
  b1:	5d                   	pop    %ebp
  b2:	c3                   	ret    

000000b3 <strlen>:

uint
strlen(char *s)
{
  b3:	55                   	push   %ebp
  b4:	89 e5                	mov    %esp,%ebp
  b6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  b9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  c0:	eb 03                	jmp    c5 <strlen+0x12>
  c2:	ff 45 fc             	incl   -0x4(%ebp)
  c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	01 d0                	add    %edx,%eax
  cd:	8a 00                	mov    (%eax),%al
  cf:	84 c0                	test   %al,%al
  d1:	75 ef                	jne    c2 <strlen+0xf>
    ;
  return n;
  d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d6:	c9                   	leave  
  d7:	c3                   	ret    

000000d8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d8:	55                   	push   %ebp
  d9:	89 e5                	mov    %esp,%ebp
  db:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  de:	8b 45 10             	mov    0x10(%ebp),%eax
  e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  ec:	8b 45 08             	mov    0x8(%ebp),%eax
  ef:	89 04 24             	mov    %eax,(%esp)
  f2:	e8 2d ff ff ff       	call   24 <stosb>
  return dst;
  f7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  fa:	c9                   	leave  
  fb:	c3                   	ret    

000000fc <strchr>:

char*
strchr(const char *s, char c)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	83 ec 04             	sub    $0x4,%esp
 102:	8b 45 0c             	mov    0xc(%ebp),%eax
 105:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 108:	eb 12                	jmp    11c <strchr+0x20>
    if(*s == c)
 10a:	8b 45 08             	mov    0x8(%ebp),%eax
 10d:	8a 00                	mov    (%eax),%al
 10f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 112:	75 05                	jne    119 <strchr+0x1d>
      return (char*)s;
 114:	8b 45 08             	mov    0x8(%ebp),%eax
 117:	eb 11                	jmp    12a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 119:	ff 45 08             	incl   0x8(%ebp)
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	8a 00                	mov    (%eax),%al
 121:	84 c0                	test   %al,%al
 123:	75 e5                	jne    10a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 125:	b8 00 00 00 00       	mov    $0x0,%eax
}
 12a:	c9                   	leave  
 12b:	c3                   	ret    

0000012c <gets>:

char*
gets(char *buf, int max)
{
 12c:	55                   	push   %ebp
 12d:	89 e5                	mov    %esp,%ebp
 12f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 132:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 139:	eb 42                	jmp    17d <gets+0x51>
    cc = read(0, &c, 1);
 13b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 142:	00 
 143:	8d 45 ef             	lea    -0x11(%ebp),%eax
 146:	89 44 24 04          	mov    %eax,0x4(%esp)
 14a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 151:	e8 32 01 00 00       	call   288 <read>
 156:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 159:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 15d:	7e 29                	jle    188 <gets+0x5c>
      break;
    buf[i++] = c;
 15f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	01 c2                	add    %eax,%edx
 167:	8a 45 ef             	mov    -0x11(%ebp),%al
 16a:	88 02                	mov    %al,(%edx)
 16c:	ff 45 f4             	incl   -0xc(%ebp)
    if(c == '\n' || c == '\r')
 16f:	8a 45 ef             	mov    -0x11(%ebp),%al
 172:	3c 0a                	cmp    $0xa,%al
 174:	74 13                	je     189 <gets+0x5d>
 176:	8a 45 ef             	mov    -0x11(%ebp),%al
 179:	3c 0d                	cmp    $0xd,%al
 17b:	74 0c                	je     189 <gets+0x5d>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 180:	40                   	inc    %eax
 181:	3b 45 0c             	cmp    0xc(%ebp),%eax
 184:	7c b5                	jl     13b <gets+0xf>
 186:	eb 01                	jmp    189 <gets+0x5d>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 188:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 189:	8b 55 f4             	mov    -0xc(%ebp),%edx
 18c:	8b 45 08             	mov    0x8(%ebp),%eax
 18f:	01 d0                	add    %edx,%eax
 191:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 194:	8b 45 08             	mov    0x8(%ebp),%eax
}
 197:	c9                   	leave  
 198:	c3                   	ret    

00000199 <stat>:

int
stat(char *n, struct stat *st)
{
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1a6:	00 
 1a7:	8b 45 08             	mov    0x8(%ebp),%eax
 1aa:	89 04 24             	mov    %eax,(%esp)
 1ad:	e8 fe 00 00 00       	call   2b0 <open>
 1b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1b9:	79 07                	jns    1c2 <stat+0x29>
    return -1;
 1bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c0:	eb 23                	jmp    1e5 <stat+0x4c>
  r = fstat(fd, st);
 1c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c5:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	89 04 24             	mov    %eax,(%esp)
 1cf:	e8 f4 00 00 00       	call   2c8 <fstat>
 1d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1da:	89 04 24             	mov    %eax,(%esp)
 1dd:	e8 b6 00 00 00       	call   298 <close>
  return r;
 1e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1e5:	c9                   	leave  
 1e6:	c3                   	ret    

000001e7 <atoi>:

int
atoi(const char *s)
{
 1e7:	55                   	push   %ebp
 1e8:	89 e5                	mov    %esp,%ebp
 1ea:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1ed:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1f4:	eb 21                	jmp    217 <atoi+0x30>
    n = n*10 + *s++ - '0';
 1f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1f9:	89 d0                	mov    %edx,%eax
 1fb:	c1 e0 02             	shl    $0x2,%eax
 1fe:	01 d0                	add    %edx,%eax
 200:	d1 e0                	shl    %eax
 202:	89 c2                	mov    %eax,%edx
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	8a 00                	mov    (%eax),%al
 209:	0f be c0             	movsbl %al,%eax
 20c:	01 d0                	add    %edx,%eax
 20e:	83 e8 30             	sub    $0x30,%eax
 211:	89 45 fc             	mov    %eax,-0x4(%ebp)
 214:	ff 45 08             	incl   0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 217:	8b 45 08             	mov    0x8(%ebp),%eax
 21a:	8a 00                	mov    (%eax),%al
 21c:	3c 2f                	cmp    $0x2f,%al
 21e:	7e 09                	jle    229 <atoi+0x42>
 220:	8b 45 08             	mov    0x8(%ebp),%eax
 223:	8a 00                	mov    (%eax),%al
 225:	3c 39                	cmp    $0x39,%al
 227:	7e cd                	jle    1f6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 229:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 22c:	c9                   	leave  
 22d:	c3                   	ret    

0000022e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 22e:	55                   	push   %ebp
 22f:	89 e5                	mov    %esp,%ebp
 231:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 23a:	8b 45 0c             	mov    0xc(%ebp),%eax
 23d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 240:	eb 10                	jmp    252 <memmove+0x24>
    *dst++ = *src++;
 242:	8b 45 f8             	mov    -0x8(%ebp),%eax
 245:	8a 10                	mov    (%eax),%dl
 247:	8b 45 fc             	mov    -0x4(%ebp),%eax
 24a:	88 10                	mov    %dl,(%eax)
 24c:	ff 45 fc             	incl   -0x4(%ebp)
 24f:	ff 45 f8             	incl   -0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 252:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 256:	0f 9f c0             	setg   %al
 259:	ff 4d 10             	decl   0x10(%ebp)
 25c:	84 c0                	test   %al,%al
 25e:	75 e2                	jne    242 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 260:	8b 45 08             	mov    0x8(%ebp),%eax
}
 263:	c9                   	leave  
 264:	c3                   	ret    
 265:	66 90                	xchg   %ax,%ax
 267:	90                   	nop

00000268 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 268:	b8 01 00 00 00       	mov    $0x1,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <exit>:
SYSCALL(exit)
 270:	b8 02 00 00 00       	mov    $0x2,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <wait>:
SYSCALL(wait)
 278:	b8 03 00 00 00       	mov    $0x3,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <pipe>:
SYSCALL(pipe)
 280:	b8 04 00 00 00       	mov    $0x4,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <read>:
SYSCALL(read)
 288:	b8 05 00 00 00       	mov    $0x5,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <write>:
SYSCALL(write)
 290:	b8 10 00 00 00       	mov    $0x10,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <close>:
SYSCALL(close)
 298:	b8 15 00 00 00       	mov    $0x15,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <kill>:
SYSCALL(kill)
 2a0:	b8 06 00 00 00       	mov    $0x6,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <exec>:
SYSCALL(exec)
 2a8:	b8 07 00 00 00       	mov    $0x7,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <open>:
SYSCALL(open)
 2b0:	b8 0f 00 00 00       	mov    $0xf,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <mknod>:
SYSCALL(mknod)
 2b8:	b8 11 00 00 00       	mov    $0x11,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <unlink>:
SYSCALL(unlink)
 2c0:	b8 12 00 00 00       	mov    $0x12,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <fstat>:
SYSCALL(fstat)
 2c8:	b8 08 00 00 00       	mov    $0x8,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <link>:
SYSCALL(link)
 2d0:	b8 13 00 00 00       	mov    $0x13,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <mkdir>:
SYSCALL(mkdir)
 2d8:	b8 14 00 00 00       	mov    $0x14,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <chdir>:
SYSCALL(chdir)
 2e0:	b8 09 00 00 00       	mov    $0x9,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <dup>:
SYSCALL(dup)
 2e8:	b8 0a 00 00 00       	mov    $0xa,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <getpid>:
SYSCALL(getpid)
 2f0:	b8 0b 00 00 00       	mov    $0xb,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <sbrk>:
SYSCALL(sbrk)
 2f8:	b8 0c 00 00 00       	mov    $0xc,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <sleep>:
SYSCALL(sleep)
 300:	b8 0d 00 00 00       	mov    $0xd,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <uptime>:
SYSCALL(uptime)
 308:	b8 0e 00 00 00       	mov    $0xe,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <getppid>:
SYSCALL(getppid)        // USER DEFINED SYS CALL
 310:	b8 16 00 00 00       	mov    $0x16,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <icount>:
SYSCALL(icount)         // USER DEFINED SYS CALL
 318:	b8 17 00 00 00       	mov    $0x17,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <signal>:
SYSCALL(signal)         // USER DEFINED SYS CALL
 320:	b8 18 00 00 00       	mov    $0x18,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 328:	55                   	push   %ebp
 329:	89 e5                	mov    %esp,%ebp
 32b:	83 ec 28             	sub    $0x28,%esp
 32e:	8b 45 0c             	mov    0xc(%ebp),%eax
 331:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 334:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 33b:	00 
 33c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 33f:	89 44 24 04          	mov    %eax,0x4(%esp)
 343:	8b 45 08             	mov    0x8(%ebp),%eax
 346:	89 04 24             	mov    %eax,(%esp)
 349:	e8 42 ff ff ff       	call   290 <write>
}
 34e:	c9                   	leave  
 34f:	c3                   	ret    

00000350 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 350:	55                   	push   %ebp
 351:	89 e5                	mov    %esp,%ebp
 353:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 356:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 35d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 361:	74 17                	je     37a <printint+0x2a>
 363:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 367:	79 11                	jns    37a <printint+0x2a>
    neg = 1;
 369:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 370:	8b 45 0c             	mov    0xc(%ebp),%eax
 373:	f7 d8                	neg    %eax
 375:	89 45 ec             	mov    %eax,-0x14(%ebp)
 378:	eb 06                	jmp    380 <printint+0x30>
  } else {
    x = xx;
 37a:	8b 45 0c             	mov    0xc(%ebp),%eax
 37d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 380:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 387:	8b 4d 10             	mov    0x10(%ebp),%ecx
 38a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 38d:	ba 00 00 00 00       	mov    $0x0,%edx
 392:	f7 f1                	div    %ecx
 394:	89 d0                	mov    %edx,%eax
 396:	8a 80 0c 0a 00 00    	mov    0xa0c(%eax),%al
 39c:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 39f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3a2:	01 ca                	add    %ecx,%edx
 3a4:	88 02                	mov    %al,(%edx)
 3a6:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
 3a9:	8b 55 10             	mov    0x10(%ebp),%edx
 3ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3af:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3b2:	ba 00 00 00 00       	mov    $0x0,%edx
 3b7:	f7 75 d4             	divl   -0x2c(%ebp)
 3ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3c1:	75 c4                	jne    387 <printint+0x37>
  if(neg)
 3c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3c7:	74 2c                	je     3f5 <printint+0xa5>
    buf[i++] = '-';
 3c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3cf:	01 d0                	add    %edx,%eax
 3d1:	c6 00 2d             	movb   $0x2d,(%eax)
 3d4:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
 3d7:	eb 1c                	jmp    3f5 <printint+0xa5>
    putc(fd, buf[i]);
 3d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	01 d0                	add    %edx,%eax
 3e1:	8a 00                	mov    (%eax),%al
 3e3:	0f be c0             	movsbl %al,%eax
 3e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 3ea:	8b 45 08             	mov    0x8(%ebp),%eax
 3ed:	89 04 24             	mov    %eax,(%esp)
 3f0:	e8 33 ff ff ff       	call   328 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3f5:	ff 4d f4             	decl   -0xc(%ebp)
 3f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3fc:	79 db                	jns    3d9 <printint+0x89>
    putc(fd, buf[i]);
}
 3fe:	c9                   	leave  
 3ff:	c3                   	ret    

00000400 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 400:	55                   	push   %ebp
 401:	89 e5                	mov    %esp,%ebp
 403:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 406:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 40d:	8d 45 0c             	lea    0xc(%ebp),%eax
 410:	83 c0 04             	add    $0x4,%eax
 413:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 416:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 41d:	e9 78 01 00 00       	jmp    59a <printf+0x19a>
    c = fmt[i] & 0xff;
 422:	8b 55 0c             	mov    0xc(%ebp),%edx
 425:	8b 45 f0             	mov    -0x10(%ebp),%eax
 428:	01 d0                	add    %edx,%eax
 42a:	8a 00                	mov    (%eax),%al
 42c:	0f be c0             	movsbl %al,%eax
 42f:	25 ff 00 00 00       	and    $0xff,%eax
 434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 437:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 43b:	75 2c                	jne    469 <printf+0x69>
      if(c == '%'){
 43d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 441:	75 0c                	jne    44f <printf+0x4f>
        state = '%';
 443:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 44a:	e9 48 01 00 00       	jmp    597 <printf+0x197>
      } else {
        putc(fd, c);
 44f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 452:	0f be c0             	movsbl %al,%eax
 455:	89 44 24 04          	mov    %eax,0x4(%esp)
 459:	8b 45 08             	mov    0x8(%ebp),%eax
 45c:	89 04 24             	mov    %eax,(%esp)
 45f:	e8 c4 fe ff ff       	call   328 <putc>
 464:	e9 2e 01 00 00       	jmp    597 <printf+0x197>
      }
    } else if(state == '%'){
 469:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 46d:	0f 85 24 01 00 00    	jne    597 <printf+0x197>
      if(c == 'd'){
 473:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 477:	75 2d                	jne    4a6 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 479:	8b 45 e8             	mov    -0x18(%ebp),%eax
 47c:	8b 00                	mov    (%eax),%eax
 47e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 485:	00 
 486:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 48d:	00 
 48e:	89 44 24 04          	mov    %eax,0x4(%esp)
 492:	8b 45 08             	mov    0x8(%ebp),%eax
 495:	89 04 24             	mov    %eax,(%esp)
 498:	e8 b3 fe ff ff       	call   350 <printint>
        ap++;
 49d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4a1:	e9 ea 00 00 00       	jmp    590 <printf+0x190>
      } else if(c == 'x' || c == 'p'){
 4a6:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4aa:	74 06                	je     4b2 <printf+0xb2>
 4ac:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4b0:	75 2d                	jne    4df <printf+0xdf>
        printint(fd, *ap, 16, 0);
 4b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b5:	8b 00                	mov    (%eax),%eax
 4b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4be:	00 
 4bf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4c6:	00 
 4c7:	89 44 24 04          	mov    %eax,0x4(%esp)
 4cb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ce:	89 04 24             	mov    %eax,(%esp)
 4d1:	e8 7a fe ff ff       	call   350 <printint>
        ap++;
 4d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4da:	e9 b1 00 00 00       	jmp    590 <printf+0x190>
      } else if(c == 's'){
 4df:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4e3:	75 43                	jne    528 <printf+0x128>
        s = (char*)*ap;
 4e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e8:	8b 00                	mov    (%eax),%eax
 4ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4ed:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f5:	75 25                	jne    51c <printf+0x11c>
          s = "(null)";
 4f7:	c7 45 f4 c7 07 00 00 	movl   $0x7c7,-0xc(%ebp)
        while(*s != 0){
 4fe:	eb 1c                	jmp    51c <printf+0x11c>
          putc(fd, *s);
 500:	8b 45 f4             	mov    -0xc(%ebp),%eax
 503:	8a 00                	mov    (%eax),%al
 505:	0f be c0             	movsbl %al,%eax
 508:	89 44 24 04          	mov    %eax,0x4(%esp)
 50c:	8b 45 08             	mov    0x8(%ebp),%eax
 50f:	89 04 24             	mov    %eax,(%esp)
 512:	e8 11 fe ff ff       	call   328 <putc>
          s++;
 517:	ff 45 f4             	incl   -0xc(%ebp)
 51a:	eb 01                	jmp    51d <printf+0x11d>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 51c:	90                   	nop
 51d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 520:	8a 00                	mov    (%eax),%al
 522:	84 c0                	test   %al,%al
 524:	75 da                	jne    500 <printf+0x100>
 526:	eb 68                	jmp    590 <printf+0x190>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 528:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 52c:	75 1d                	jne    54b <printf+0x14b>
        putc(fd, *ap);
 52e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 531:	8b 00                	mov    (%eax),%eax
 533:	0f be c0             	movsbl %al,%eax
 536:	89 44 24 04          	mov    %eax,0x4(%esp)
 53a:	8b 45 08             	mov    0x8(%ebp),%eax
 53d:	89 04 24             	mov    %eax,(%esp)
 540:	e8 e3 fd ff ff       	call   328 <putc>
        ap++;
 545:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 549:	eb 45                	jmp    590 <printf+0x190>
      } else if(c == '%'){
 54b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 54f:	75 17                	jne    568 <printf+0x168>
        putc(fd, c);
 551:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 554:	0f be c0             	movsbl %al,%eax
 557:	89 44 24 04          	mov    %eax,0x4(%esp)
 55b:	8b 45 08             	mov    0x8(%ebp),%eax
 55e:	89 04 24             	mov    %eax,(%esp)
 561:	e8 c2 fd ff ff       	call   328 <putc>
 566:	eb 28                	jmp    590 <printf+0x190>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 568:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 56f:	00 
 570:	8b 45 08             	mov    0x8(%ebp),%eax
 573:	89 04 24             	mov    %eax,(%esp)
 576:	e8 ad fd ff ff       	call   328 <putc>
        putc(fd, c);
 57b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 57e:	0f be c0             	movsbl %al,%eax
 581:	89 44 24 04          	mov    %eax,0x4(%esp)
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	89 04 24             	mov    %eax,(%esp)
 58b:	e8 98 fd ff ff       	call   328 <putc>
      }
      state = 0;
 590:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 597:	ff 45 f0             	incl   -0x10(%ebp)
 59a:	8b 55 0c             	mov    0xc(%ebp),%edx
 59d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5a0:	01 d0                	add    %edx,%eax
 5a2:	8a 00                	mov    (%eax),%al
 5a4:	84 c0                	test   %al,%al
 5a6:	0f 85 76 fe ff ff    	jne    422 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5ac:	c9                   	leave  
 5ad:	c3                   	ret    
 5ae:	66 90                	xchg   %ax,%ax

000005b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5b6:	8b 45 08             	mov    0x8(%ebp),%eax
 5b9:	83 e8 08             	sub    $0x8,%eax
 5bc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5bf:	a1 28 0a 00 00       	mov    0xa28,%eax
 5c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5c7:	eb 24                	jmp    5ed <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5cc:	8b 00                	mov    (%eax),%eax
 5ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d1:	77 12                	ja     5e5 <free+0x35>
 5d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d9:	77 24                	ja     5ff <free+0x4f>
 5db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5de:	8b 00                	mov    (%eax),%eax
 5e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5e3:	77 1a                	ja     5ff <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e8:	8b 00                	mov    (%eax),%eax
 5ea:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5f3:	76 d4                	jbe    5c9 <free+0x19>
 5f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f8:	8b 00                	mov    (%eax),%eax
 5fa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5fd:	76 ca                	jbe    5c9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
 602:	8b 40 04             	mov    0x4(%eax),%eax
 605:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 60c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60f:	01 c2                	add    %eax,%edx
 611:	8b 45 fc             	mov    -0x4(%ebp),%eax
 614:	8b 00                	mov    (%eax),%eax
 616:	39 c2                	cmp    %eax,%edx
 618:	75 24                	jne    63e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 61a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61d:	8b 50 04             	mov    0x4(%eax),%edx
 620:	8b 45 fc             	mov    -0x4(%ebp),%eax
 623:	8b 00                	mov    (%eax),%eax
 625:	8b 40 04             	mov    0x4(%eax),%eax
 628:	01 c2                	add    %eax,%edx
 62a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 630:	8b 45 fc             	mov    -0x4(%ebp),%eax
 633:	8b 00                	mov    (%eax),%eax
 635:	8b 10                	mov    (%eax),%edx
 637:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63a:	89 10                	mov    %edx,(%eax)
 63c:	eb 0a                	jmp    648 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 63e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 641:	8b 10                	mov    (%eax),%edx
 643:	8b 45 f8             	mov    -0x8(%ebp),%eax
 646:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8b 40 04             	mov    0x4(%eax),%eax
 64e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 655:	8b 45 fc             	mov    -0x4(%ebp),%eax
 658:	01 d0                	add    %edx,%eax
 65a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 65d:	75 20                	jne    67f <free+0xcf>
    p->s.size += bp->s.size;
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	8b 50 04             	mov    0x4(%eax),%edx
 665:	8b 45 f8             	mov    -0x8(%ebp),%eax
 668:	8b 40 04             	mov    0x4(%eax),%eax
 66b:	01 c2                	add    %eax,%edx
 66d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 670:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 673:	8b 45 f8             	mov    -0x8(%ebp),%eax
 676:	8b 10                	mov    (%eax),%edx
 678:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67b:	89 10                	mov    %edx,(%eax)
 67d:	eb 08                	jmp    687 <free+0xd7>
  } else
    p->s.ptr = bp;
 67f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 682:	8b 55 f8             	mov    -0x8(%ebp),%edx
 685:	89 10                	mov    %edx,(%eax)
  freep = p;
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	a3 28 0a 00 00       	mov    %eax,0xa28
}
 68f:	c9                   	leave  
 690:	c3                   	ret    

00000691 <morecore>:

static Header*
morecore(uint nu)
{
 691:	55                   	push   %ebp
 692:	89 e5                	mov    %esp,%ebp
 694:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 697:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 69e:	77 07                	ja     6a7 <morecore+0x16>
    nu = 4096;
 6a0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6a7:	8b 45 08             	mov    0x8(%ebp),%eax
 6aa:	c1 e0 03             	shl    $0x3,%eax
 6ad:	89 04 24             	mov    %eax,(%esp)
 6b0:	e8 43 fc ff ff       	call   2f8 <sbrk>
 6b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6b8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6bc:	75 07                	jne    6c5 <morecore+0x34>
    return 0;
 6be:	b8 00 00 00 00       	mov    $0x0,%eax
 6c3:	eb 22                	jmp    6e7 <morecore+0x56>
  hp = (Header*)p;
 6c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ce:	8b 55 08             	mov    0x8(%ebp),%edx
 6d1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d7:	83 c0 08             	add    $0x8,%eax
 6da:	89 04 24             	mov    %eax,(%esp)
 6dd:	e8 ce fe ff ff       	call   5b0 <free>
  return freep;
 6e2:	a1 28 0a 00 00       	mov    0xa28,%eax
}
 6e7:	c9                   	leave  
 6e8:	c3                   	ret    

000006e9 <malloc>:

void*
malloc(uint nbytes)
{
 6e9:	55                   	push   %ebp
 6ea:	89 e5                	mov    %esp,%ebp
 6ec:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6ef:	8b 45 08             	mov    0x8(%ebp),%eax
 6f2:	83 c0 07             	add    $0x7,%eax
 6f5:	c1 e8 03             	shr    $0x3,%eax
 6f8:	40                   	inc    %eax
 6f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6fc:	a1 28 0a 00 00       	mov    0xa28,%eax
 701:	89 45 f0             	mov    %eax,-0x10(%ebp)
 704:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 708:	75 23                	jne    72d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 70a:	c7 45 f0 20 0a 00 00 	movl   $0xa20,-0x10(%ebp)
 711:	8b 45 f0             	mov    -0x10(%ebp),%eax
 714:	a3 28 0a 00 00       	mov    %eax,0xa28
 719:	a1 28 0a 00 00       	mov    0xa28,%eax
 71e:	a3 20 0a 00 00       	mov    %eax,0xa20
    base.s.size = 0;
 723:	c7 05 24 0a 00 00 00 	movl   $0x0,0xa24
 72a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 72d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 730:	8b 00                	mov    (%eax),%eax
 732:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 735:	8b 45 f4             	mov    -0xc(%ebp),%eax
 738:	8b 40 04             	mov    0x4(%eax),%eax
 73b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 73e:	72 4d                	jb     78d <malloc+0xa4>
      if(p->s.size == nunits)
 740:	8b 45 f4             	mov    -0xc(%ebp),%eax
 743:	8b 40 04             	mov    0x4(%eax),%eax
 746:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 749:	75 0c                	jne    757 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 74b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74e:	8b 10                	mov    (%eax),%edx
 750:	8b 45 f0             	mov    -0x10(%ebp),%eax
 753:	89 10                	mov    %edx,(%eax)
 755:	eb 26                	jmp    77d <malloc+0x94>
      else {
        p->s.size -= nunits;
 757:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75a:	8b 40 04             	mov    0x4(%eax),%eax
 75d:	89 c2                	mov    %eax,%edx
 75f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 762:	8b 45 f4             	mov    -0xc(%ebp),%eax
 765:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 768:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76b:	8b 40 04             	mov    0x4(%eax),%eax
 76e:	c1 e0 03             	shl    $0x3,%eax
 771:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 774:	8b 45 f4             	mov    -0xc(%ebp),%eax
 777:	8b 55 ec             	mov    -0x14(%ebp),%edx
 77a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 77d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 780:	a3 28 0a 00 00       	mov    %eax,0xa28
      return (void*)(p + 1);
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	83 c0 08             	add    $0x8,%eax
 78b:	eb 38                	jmp    7c5 <malloc+0xdc>
    }
    if(p == freep)
 78d:	a1 28 0a 00 00       	mov    0xa28,%eax
 792:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 795:	75 1b                	jne    7b2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 797:	8b 45 ec             	mov    -0x14(%ebp),%eax
 79a:	89 04 24             	mov    %eax,(%esp)
 79d:	e8 ef fe ff ff       	call   691 <morecore>
 7a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a9:	75 07                	jne    7b2 <malloc+0xc9>
        return 0;
 7ab:	b8 00 00 00 00       	mov    $0x0,%eax
 7b0:	eb 13                	jmp    7c5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bb:	8b 00                	mov    (%eax),%eax
 7bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7c0:	e9 70 ff ff ff       	jmp    735 <malloc+0x4c>
}
 7c5:	c9                   	leave  
 7c6:	c3                   	ret    
