
_hw02:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
//#include "syscall.h"
#include "traps.h"

int main(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 10             	sub    $0x10,%esp
    printf(1, "# of Keyboard Interrupts: %d\n", icount());
   9:	e8 12 03 00 00       	call   320 <icount>
   e:	89 44 24 08          	mov    %eax,0x8(%esp)
  12:	c7 44 24 04 cf 07 00 	movl   $0x7cf,0x4(%esp)
  19:	00 
  1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  21:	e8 e2 03 00 00       	call   408 <printf>
        
    exit();
  26:	e8 4d 02 00 00       	call   278 <exit>
  2b:	90                   	nop

0000002c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  2c:	55                   	push   %ebp
  2d:	89 e5                	mov    %esp,%ebp
  2f:	57                   	push   %edi
  30:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  34:	8b 55 10             	mov    0x10(%ebp),%edx
  37:	8b 45 0c             	mov    0xc(%ebp),%eax
  3a:	89 cb                	mov    %ecx,%ebx
  3c:	89 df                	mov    %ebx,%edi
  3e:	89 d1                	mov    %edx,%ecx
  40:	fc                   	cld    
  41:	f3 aa                	rep stos %al,%es:(%edi)
  43:	89 ca                	mov    %ecx,%edx
  45:	89 fb                	mov    %edi,%ebx
  47:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  4d:	5b                   	pop    %ebx
  4e:	5f                   	pop    %edi
  4f:	5d                   	pop    %ebp
  50:	c3                   	ret    

00000051 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  51:	55                   	push   %ebp
  52:	89 e5                	mov    %esp,%ebp
  54:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  57:	8b 45 08             	mov    0x8(%ebp),%eax
  5a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  5d:	90                   	nop
  5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  61:	8a 10                	mov    (%eax),%dl
  63:	8b 45 08             	mov    0x8(%ebp),%eax
  66:	88 10                	mov    %dl,(%eax)
  68:	8b 45 08             	mov    0x8(%ebp),%eax
  6b:	8a 00                	mov    (%eax),%al
  6d:	84 c0                	test   %al,%al
  6f:	0f 95 c0             	setne  %al
  72:	ff 45 08             	incl   0x8(%ebp)
  75:	ff 45 0c             	incl   0xc(%ebp)
  78:	84 c0                	test   %al,%al
  7a:	75 e2                	jne    5e <strcpy+0xd>
    ;
  return os;
  7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  7f:	c9                   	leave  
  80:	c3                   	ret    

00000081 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  81:	55                   	push   %ebp
  82:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  84:	eb 06                	jmp    8c <strcmp+0xb>
    p++, q++;
  86:	ff 45 08             	incl   0x8(%ebp)
  89:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  8c:	8b 45 08             	mov    0x8(%ebp),%eax
  8f:	8a 00                	mov    (%eax),%al
  91:	84 c0                	test   %al,%al
  93:	74 0e                	je     a3 <strcmp+0x22>
  95:	8b 45 08             	mov    0x8(%ebp),%eax
  98:	8a 10                	mov    (%eax),%dl
  9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  9d:	8a 00                	mov    (%eax),%al
  9f:	38 c2                	cmp    %al,%dl
  a1:	74 e3                	je     86 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  a3:	8b 45 08             	mov    0x8(%ebp),%eax
  a6:	8a 00                	mov    (%eax),%al
  a8:	0f b6 d0             	movzbl %al,%edx
  ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  ae:	8a 00                	mov    (%eax),%al
  b0:	0f b6 c0             	movzbl %al,%eax
  b3:	89 d1                	mov    %edx,%ecx
  b5:	29 c1                	sub    %eax,%ecx
  b7:	89 c8                	mov    %ecx,%eax
}
  b9:	5d                   	pop    %ebp
  ba:	c3                   	ret    

000000bb <strlen>:

uint
strlen(char *s)
{
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  be:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  c8:	eb 03                	jmp    cd <strlen+0x12>
  ca:	ff 45 fc             	incl   -0x4(%ebp)
  cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  d0:	8b 45 08             	mov    0x8(%ebp),%eax
  d3:	01 d0                	add    %edx,%eax
  d5:	8a 00                	mov    (%eax),%al
  d7:	84 c0                	test   %al,%al
  d9:	75 ef                	jne    ca <strlen+0xf>
    ;
  return n;
  db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  de:	c9                   	leave  
  df:	c3                   	ret    

000000e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e0:	55                   	push   %ebp
  e1:	89 e5                	mov    %esp,%ebp
  e3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
  e6:	8b 45 10             	mov    0x10(%ebp),%eax
  e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  f4:	8b 45 08             	mov    0x8(%ebp),%eax
  f7:	89 04 24             	mov    %eax,(%esp)
  fa:	e8 2d ff ff ff       	call   2c <stosb>
  return dst;
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
}
 102:	c9                   	leave  
 103:	c3                   	ret    

00000104 <strchr>:

char*
strchr(const char *s, char c)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	83 ec 04             	sub    $0x4,%esp
 10a:	8b 45 0c             	mov    0xc(%ebp),%eax
 10d:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 110:	eb 12                	jmp    124 <strchr+0x20>
    if(*s == c)
 112:	8b 45 08             	mov    0x8(%ebp),%eax
 115:	8a 00                	mov    (%eax),%al
 117:	3a 45 fc             	cmp    -0x4(%ebp),%al
 11a:	75 05                	jne    121 <strchr+0x1d>
      return (char*)s;
 11c:	8b 45 08             	mov    0x8(%ebp),%eax
 11f:	eb 11                	jmp    132 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 121:	ff 45 08             	incl   0x8(%ebp)
 124:	8b 45 08             	mov    0x8(%ebp),%eax
 127:	8a 00                	mov    (%eax),%al
 129:	84 c0                	test   %al,%al
 12b:	75 e5                	jne    112 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 12d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 132:	c9                   	leave  
 133:	c3                   	ret    

00000134 <gets>:

char*
gets(char *buf, int max)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 141:	eb 42                	jmp    185 <gets+0x51>
    cc = read(0, &c, 1);
 143:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 14a:	00 
 14b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 14e:	89 44 24 04          	mov    %eax,0x4(%esp)
 152:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 159:	e8 32 01 00 00       	call   290 <read>
 15e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 161:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 165:	7e 29                	jle    190 <gets+0x5c>
      break;
    buf[i++] = c;
 167:	8b 55 f4             	mov    -0xc(%ebp),%edx
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	01 c2                	add    %eax,%edx
 16f:	8a 45 ef             	mov    -0x11(%ebp),%al
 172:	88 02                	mov    %al,(%edx)
 174:	ff 45 f4             	incl   -0xc(%ebp)
    if(c == '\n' || c == '\r')
 177:	8a 45 ef             	mov    -0x11(%ebp),%al
 17a:	3c 0a                	cmp    $0xa,%al
 17c:	74 13                	je     191 <gets+0x5d>
 17e:	8a 45 ef             	mov    -0x11(%ebp),%al
 181:	3c 0d                	cmp    $0xd,%al
 183:	74 0c                	je     191 <gets+0x5d>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 185:	8b 45 f4             	mov    -0xc(%ebp),%eax
 188:	40                   	inc    %eax
 189:	3b 45 0c             	cmp    0xc(%ebp),%eax
 18c:	7c b5                	jl     143 <gets+0xf>
 18e:	eb 01                	jmp    191 <gets+0x5d>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 190:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 191:	8b 55 f4             	mov    -0xc(%ebp),%edx
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	01 d0                	add    %edx,%eax
 199:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 19f:	c9                   	leave  
 1a0:	c3                   	ret    

000001a1 <stat>:

int
stat(char *n, struct stat *st)
{
 1a1:	55                   	push   %ebp
 1a2:	89 e5                	mov    %esp,%ebp
 1a4:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 1ae:	00 
 1af:	8b 45 08             	mov    0x8(%ebp),%eax
 1b2:	89 04 24             	mov    %eax,(%esp)
 1b5:	e8 fe 00 00 00       	call   2b8 <open>
 1ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c1:	79 07                	jns    1ca <stat+0x29>
    return -1;
 1c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1c8:	eb 23                	jmp    1ed <stat+0x4c>
  r = fstat(fd, st);
 1ca:	8b 45 0c             	mov    0xc(%ebp),%eax
 1cd:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d4:	89 04 24             	mov    %eax,(%esp)
 1d7:	e8 f4 00 00 00       	call   2d0 <fstat>
 1dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1df:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1e2:	89 04 24             	mov    %eax,(%esp)
 1e5:	e8 b6 00 00 00       	call   2a0 <close>
  return r;
 1ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1ed:	c9                   	leave  
 1ee:	c3                   	ret    

000001ef <atoi>:

int
atoi(const char *s)
{
 1ef:	55                   	push   %ebp
 1f0:	89 e5                	mov    %esp,%ebp
 1f2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1f5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 1fc:	eb 21                	jmp    21f <atoi+0x30>
    n = n*10 + *s++ - '0';
 1fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
 201:	89 d0                	mov    %edx,%eax
 203:	c1 e0 02             	shl    $0x2,%eax
 206:	01 d0                	add    %edx,%eax
 208:	d1 e0                	shl    %eax
 20a:	89 c2                	mov    %eax,%edx
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
 20f:	8a 00                	mov    (%eax),%al
 211:	0f be c0             	movsbl %al,%eax
 214:	01 d0                	add    %edx,%eax
 216:	83 e8 30             	sub    $0x30,%eax
 219:	89 45 fc             	mov    %eax,-0x4(%ebp)
 21c:	ff 45 08             	incl   0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 21f:	8b 45 08             	mov    0x8(%ebp),%eax
 222:	8a 00                	mov    (%eax),%al
 224:	3c 2f                	cmp    $0x2f,%al
 226:	7e 09                	jle    231 <atoi+0x42>
 228:	8b 45 08             	mov    0x8(%ebp),%eax
 22b:	8a 00                	mov    (%eax),%al
 22d:	3c 39                	cmp    $0x39,%al
 22f:	7e cd                	jle    1fe <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 231:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 234:	c9                   	leave  
 235:	c3                   	ret    

00000236 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 236:	55                   	push   %ebp
 237:	89 e5                	mov    %esp,%ebp
 239:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
 23f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 242:	8b 45 0c             	mov    0xc(%ebp),%eax
 245:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 248:	eb 10                	jmp    25a <memmove+0x24>
    *dst++ = *src++;
 24a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 24d:	8a 10                	mov    (%eax),%dl
 24f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 252:	88 10                	mov    %dl,(%eax)
 254:	ff 45 fc             	incl   -0x4(%ebp)
 257:	ff 45 f8             	incl   -0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 25a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 25e:	0f 9f c0             	setg   %al
 261:	ff 4d 10             	decl   0x10(%ebp)
 264:	84 c0                	test   %al,%al
 266:	75 e2                	jne    24a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 268:	8b 45 08             	mov    0x8(%ebp),%eax
}
 26b:	c9                   	leave  
 26c:	c3                   	ret    
 26d:	66 90                	xchg   %ax,%ax
 26f:	90                   	nop

00000270 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 270:	b8 01 00 00 00       	mov    $0x1,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <exit>:
SYSCALL(exit)
 278:	b8 02 00 00 00       	mov    $0x2,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <wait>:
SYSCALL(wait)
 280:	b8 03 00 00 00       	mov    $0x3,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <pipe>:
SYSCALL(pipe)
 288:	b8 04 00 00 00       	mov    $0x4,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <read>:
SYSCALL(read)
 290:	b8 05 00 00 00       	mov    $0x5,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <write>:
SYSCALL(write)
 298:	b8 10 00 00 00       	mov    $0x10,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <close>:
SYSCALL(close)
 2a0:	b8 15 00 00 00       	mov    $0x15,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <kill>:
SYSCALL(kill)
 2a8:	b8 06 00 00 00       	mov    $0x6,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <exec>:
SYSCALL(exec)
 2b0:	b8 07 00 00 00       	mov    $0x7,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <open>:
SYSCALL(open)
 2b8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <mknod>:
SYSCALL(mknod)
 2c0:	b8 11 00 00 00       	mov    $0x11,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <unlink>:
SYSCALL(unlink)
 2c8:	b8 12 00 00 00       	mov    $0x12,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <fstat>:
SYSCALL(fstat)
 2d0:	b8 08 00 00 00       	mov    $0x8,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <link>:
SYSCALL(link)
 2d8:	b8 13 00 00 00       	mov    $0x13,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <mkdir>:
SYSCALL(mkdir)
 2e0:	b8 14 00 00 00       	mov    $0x14,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <chdir>:
SYSCALL(chdir)
 2e8:	b8 09 00 00 00       	mov    $0x9,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <dup>:
SYSCALL(dup)
 2f0:	b8 0a 00 00 00       	mov    $0xa,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <getpid>:
SYSCALL(getpid)
 2f8:	b8 0b 00 00 00       	mov    $0xb,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <sbrk>:
SYSCALL(sbrk)
 300:	b8 0c 00 00 00       	mov    $0xc,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <sleep>:
SYSCALL(sleep)
 308:	b8 0d 00 00 00       	mov    $0xd,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <uptime>:
SYSCALL(uptime)
 310:	b8 0e 00 00 00       	mov    $0xe,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <getppid>:
SYSCALL(getppid)        // USER DEFINED SYS CALL
 318:	b8 16 00 00 00       	mov    $0x16,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <icount>:
SYSCALL(icount)         // USER DEFINED SYS CALL
 320:	b8 17 00 00 00       	mov    $0x17,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <signal>:
SYSCALL(signal)         // USER DEFINED SYS CALL
 328:	b8 18 00 00 00       	mov    $0x18,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 330:	55                   	push   %ebp
 331:	89 e5                	mov    %esp,%ebp
 333:	83 ec 28             	sub    $0x28,%esp
 336:	8b 45 0c             	mov    0xc(%ebp),%eax
 339:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 33c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 343:	00 
 344:	8d 45 f4             	lea    -0xc(%ebp),%eax
 347:	89 44 24 04          	mov    %eax,0x4(%esp)
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	89 04 24             	mov    %eax,(%esp)
 351:	e8 42 ff ff ff       	call   298 <write>
}
 356:	c9                   	leave  
 357:	c3                   	ret    

00000358 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 35e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 365:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 369:	74 17                	je     382 <printint+0x2a>
 36b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 36f:	79 11                	jns    382 <printint+0x2a>
    neg = 1;
 371:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 378:	8b 45 0c             	mov    0xc(%ebp),%eax
 37b:	f7 d8                	neg    %eax
 37d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 380:	eb 06                	jmp    388 <printint+0x30>
  } else {
    x = xx;
 382:	8b 45 0c             	mov    0xc(%ebp),%eax
 385:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 388:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 38f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 392:	8b 45 ec             	mov    -0x14(%ebp),%eax
 395:	ba 00 00 00 00       	mov    $0x0,%edx
 39a:	f7 f1                	div    %ecx
 39c:	89 d0                	mov    %edx,%eax
 39e:	8a 80 30 0a 00 00    	mov    0xa30(%eax),%al
 3a4:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 3a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3aa:	01 ca                	add    %ecx,%edx
 3ac:	88 02                	mov    %al,(%edx)
 3ae:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
 3b1:	8b 55 10             	mov    0x10(%ebp),%edx
 3b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 3b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ba:	ba 00 00 00 00       	mov    $0x0,%edx
 3bf:	f7 75 d4             	divl   -0x2c(%ebp)
 3c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3c5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3c9:	75 c4                	jne    38f <printint+0x37>
  if(neg)
 3cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3cf:	74 2c                	je     3fd <printint+0xa5>
    buf[i++] = '-';
 3d1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d7:	01 d0                	add    %edx,%eax
 3d9:	c6 00 2d             	movb   $0x2d,(%eax)
 3dc:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
 3df:	eb 1c                	jmp    3fd <printint+0xa5>
    putc(fd, buf[i]);
 3e1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e7:	01 d0                	add    %edx,%eax
 3e9:	8a 00                	mov    (%eax),%al
 3eb:	0f be c0             	movsbl %al,%eax
 3ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 3f2:	8b 45 08             	mov    0x8(%ebp),%eax
 3f5:	89 04 24             	mov    %eax,(%esp)
 3f8:	e8 33 ff ff ff       	call   330 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3fd:	ff 4d f4             	decl   -0xc(%ebp)
 400:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 404:	79 db                	jns    3e1 <printint+0x89>
    putc(fd, buf[i]);
}
 406:	c9                   	leave  
 407:	c3                   	ret    

00000408 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 408:	55                   	push   %ebp
 409:	89 e5                	mov    %esp,%ebp
 40b:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 40e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 415:	8d 45 0c             	lea    0xc(%ebp),%eax
 418:	83 c0 04             	add    $0x4,%eax
 41b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 41e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 425:	e9 78 01 00 00       	jmp    5a2 <printf+0x19a>
    c = fmt[i] & 0xff;
 42a:	8b 55 0c             	mov    0xc(%ebp),%edx
 42d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 430:	01 d0                	add    %edx,%eax
 432:	8a 00                	mov    (%eax),%al
 434:	0f be c0             	movsbl %al,%eax
 437:	25 ff 00 00 00       	and    $0xff,%eax
 43c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 43f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 443:	75 2c                	jne    471 <printf+0x69>
      if(c == '%'){
 445:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 449:	75 0c                	jne    457 <printf+0x4f>
        state = '%';
 44b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 452:	e9 48 01 00 00       	jmp    59f <printf+0x197>
      } else {
        putc(fd, c);
 457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 45a:	0f be c0             	movsbl %al,%eax
 45d:	89 44 24 04          	mov    %eax,0x4(%esp)
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	89 04 24             	mov    %eax,(%esp)
 467:	e8 c4 fe ff ff       	call   330 <putc>
 46c:	e9 2e 01 00 00       	jmp    59f <printf+0x197>
      }
    } else if(state == '%'){
 471:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 475:	0f 85 24 01 00 00    	jne    59f <printf+0x197>
      if(c == 'd'){
 47b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 47f:	75 2d                	jne    4ae <printf+0xa6>
        printint(fd, *ap, 10, 1);
 481:	8b 45 e8             	mov    -0x18(%ebp),%eax
 484:	8b 00                	mov    (%eax),%eax
 486:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 48d:	00 
 48e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 495:	00 
 496:	89 44 24 04          	mov    %eax,0x4(%esp)
 49a:	8b 45 08             	mov    0x8(%ebp),%eax
 49d:	89 04 24             	mov    %eax,(%esp)
 4a0:	e8 b3 fe ff ff       	call   358 <printint>
        ap++;
 4a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4a9:	e9 ea 00 00 00       	jmp    598 <printf+0x190>
      } else if(c == 'x' || c == 'p'){
 4ae:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4b2:	74 06                	je     4ba <printf+0xb2>
 4b4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4b8:	75 2d                	jne    4e7 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 4ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4bd:	8b 00                	mov    (%eax),%eax
 4bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 4c6:	00 
 4c7:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 4ce:	00 
 4cf:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d3:	8b 45 08             	mov    0x8(%ebp),%eax
 4d6:	89 04 24             	mov    %eax,(%esp)
 4d9:	e8 7a fe ff ff       	call   358 <printint>
        ap++;
 4de:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4e2:	e9 b1 00 00 00       	jmp    598 <printf+0x190>
      } else if(c == 's'){
 4e7:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4eb:	75 43                	jne    530 <printf+0x128>
        s = (char*)*ap;
 4ed:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f0:	8b 00                	mov    (%eax),%eax
 4f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fd:	75 25                	jne    524 <printf+0x11c>
          s = "(null)";
 4ff:	c7 45 f4 ed 07 00 00 	movl   $0x7ed,-0xc(%ebp)
        while(*s != 0){
 506:	eb 1c                	jmp    524 <printf+0x11c>
          putc(fd, *s);
 508:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50b:	8a 00                	mov    (%eax),%al
 50d:	0f be c0             	movsbl %al,%eax
 510:	89 44 24 04          	mov    %eax,0x4(%esp)
 514:	8b 45 08             	mov    0x8(%ebp),%eax
 517:	89 04 24             	mov    %eax,(%esp)
 51a:	e8 11 fe ff ff       	call   330 <putc>
          s++;
 51f:	ff 45 f4             	incl   -0xc(%ebp)
 522:	eb 01                	jmp    525 <printf+0x11d>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 524:	90                   	nop
 525:	8b 45 f4             	mov    -0xc(%ebp),%eax
 528:	8a 00                	mov    (%eax),%al
 52a:	84 c0                	test   %al,%al
 52c:	75 da                	jne    508 <printf+0x100>
 52e:	eb 68                	jmp    598 <printf+0x190>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 530:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 534:	75 1d                	jne    553 <printf+0x14b>
        putc(fd, *ap);
 536:	8b 45 e8             	mov    -0x18(%ebp),%eax
 539:	8b 00                	mov    (%eax),%eax
 53b:	0f be c0             	movsbl %al,%eax
 53e:	89 44 24 04          	mov    %eax,0x4(%esp)
 542:	8b 45 08             	mov    0x8(%ebp),%eax
 545:	89 04 24             	mov    %eax,(%esp)
 548:	e8 e3 fd ff ff       	call   330 <putc>
        ap++;
 54d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 551:	eb 45                	jmp    598 <printf+0x190>
      } else if(c == '%'){
 553:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 557:	75 17                	jne    570 <printf+0x168>
        putc(fd, c);
 559:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55c:	0f be c0             	movsbl %al,%eax
 55f:	89 44 24 04          	mov    %eax,0x4(%esp)
 563:	8b 45 08             	mov    0x8(%ebp),%eax
 566:	89 04 24             	mov    %eax,(%esp)
 569:	e8 c2 fd ff ff       	call   330 <putc>
 56e:	eb 28                	jmp    598 <printf+0x190>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 570:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 577:	00 
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	89 04 24             	mov    %eax,(%esp)
 57e:	e8 ad fd ff ff       	call   330 <putc>
        putc(fd, c);
 583:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 586:	0f be c0             	movsbl %al,%eax
 589:	89 44 24 04          	mov    %eax,0x4(%esp)
 58d:	8b 45 08             	mov    0x8(%ebp),%eax
 590:	89 04 24             	mov    %eax,(%esp)
 593:	e8 98 fd ff ff       	call   330 <putc>
      }
      state = 0;
 598:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 59f:	ff 45 f0             	incl   -0x10(%ebp)
 5a2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5a8:	01 d0                	add    %edx,%eax
 5aa:	8a 00                	mov    (%eax),%al
 5ac:	84 c0                	test   %al,%al
 5ae:	0f 85 76 fe ff ff    	jne    42a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5b4:	c9                   	leave  
 5b5:	c3                   	ret    
 5b6:	66 90                	xchg   %ax,%ax

000005b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5b8:	55                   	push   %ebp
 5b9:	89 e5                	mov    %esp,%ebp
 5bb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5be:	8b 45 08             	mov    0x8(%ebp),%eax
 5c1:	83 e8 08             	sub    $0x8,%eax
 5c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c7:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 5cc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5cf:	eb 24                	jmp    5f5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d4:	8b 00                	mov    (%eax),%eax
 5d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5d9:	77 12                	ja     5ed <free+0x35>
 5db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5de:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5e1:	77 24                	ja     607 <free+0x4f>
 5e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e6:	8b 00                	mov    (%eax),%eax
 5e8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5eb:	77 1a                	ja     607 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f0:	8b 00                	mov    (%eax),%eax
 5f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5fb:	76 d4                	jbe    5d1 <free+0x19>
 5fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 605:	76 ca                	jbe    5d1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 607:	8b 45 f8             	mov    -0x8(%ebp),%eax
 60a:	8b 40 04             	mov    0x4(%eax),%eax
 60d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 614:	8b 45 f8             	mov    -0x8(%ebp),%eax
 617:	01 c2                	add    %eax,%edx
 619:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61c:	8b 00                	mov    (%eax),%eax
 61e:	39 c2                	cmp    %eax,%edx
 620:	75 24                	jne    646 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 622:	8b 45 f8             	mov    -0x8(%ebp),%eax
 625:	8b 50 04             	mov    0x4(%eax),%edx
 628:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62b:	8b 00                	mov    (%eax),%eax
 62d:	8b 40 04             	mov    0x4(%eax),%eax
 630:	01 c2                	add    %eax,%edx
 632:	8b 45 f8             	mov    -0x8(%ebp),%eax
 635:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	8b 10                	mov    (%eax),%edx
 63f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 642:	89 10                	mov    %edx,(%eax)
 644:	eb 0a                	jmp    650 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 646:	8b 45 fc             	mov    -0x4(%ebp),%eax
 649:	8b 10                	mov    (%eax),%edx
 64b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 650:	8b 45 fc             	mov    -0x4(%ebp),%eax
 653:	8b 40 04             	mov    0x4(%eax),%eax
 656:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 65d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 660:	01 d0                	add    %edx,%eax
 662:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 665:	75 20                	jne    687 <free+0xcf>
    p->s.size += bp->s.size;
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 50 04             	mov    0x4(%eax),%edx
 66d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 670:	8b 40 04             	mov    0x4(%eax),%eax
 673:	01 c2                	add    %eax,%edx
 675:	8b 45 fc             	mov    -0x4(%ebp),%eax
 678:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 67b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 67e:	8b 10                	mov    (%eax),%edx
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	89 10                	mov    %edx,(%eax)
 685:	eb 08                	jmp    68f <free+0xd7>
  } else
    p->s.ptr = bp;
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 68d:	89 10                	mov    %edx,(%eax)
  freep = p;
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	a3 4c 0a 00 00       	mov    %eax,0xa4c
}
 697:	c9                   	leave  
 698:	c3                   	ret    

00000699 <morecore>:

static Header*
morecore(uint nu)
{
 699:	55                   	push   %ebp
 69a:	89 e5                	mov    %esp,%ebp
 69c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 69f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6a6:	77 07                	ja     6af <morecore+0x16>
    nu = 4096;
 6a8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6af:	8b 45 08             	mov    0x8(%ebp),%eax
 6b2:	c1 e0 03             	shl    $0x3,%eax
 6b5:	89 04 24             	mov    %eax,(%esp)
 6b8:	e8 43 fc ff ff       	call   300 <sbrk>
 6bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6c0:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6c4:	75 07                	jne    6cd <morecore+0x34>
    return 0;
 6c6:	b8 00 00 00 00       	mov    $0x0,%eax
 6cb:	eb 22                	jmp    6ef <morecore+0x56>
  hp = (Header*)p;
 6cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d6:	8b 55 08             	mov    0x8(%ebp),%edx
 6d9:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6df:	83 c0 08             	add    $0x8,%eax
 6e2:	89 04 24             	mov    %eax,(%esp)
 6e5:	e8 ce fe ff ff       	call   5b8 <free>
  return freep;
 6ea:	a1 4c 0a 00 00       	mov    0xa4c,%eax
}
 6ef:	c9                   	leave  
 6f0:	c3                   	ret    

000006f1 <malloc>:

void*
malloc(uint nbytes)
{
 6f1:	55                   	push   %ebp
 6f2:	89 e5                	mov    %esp,%ebp
 6f4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6f7:	8b 45 08             	mov    0x8(%ebp),%eax
 6fa:	83 c0 07             	add    $0x7,%eax
 6fd:	c1 e8 03             	shr    $0x3,%eax
 700:	40                   	inc    %eax
 701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 704:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 709:	89 45 f0             	mov    %eax,-0x10(%ebp)
 70c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 710:	75 23                	jne    735 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 712:	c7 45 f0 44 0a 00 00 	movl   $0xa44,-0x10(%ebp)
 719:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71c:	a3 4c 0a 00 00       	mov    %eax,0xa4c
 721:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 726:	a3 44 0a 00 00       	mov    %eax,0xa44
    base.s.size = 0;
 72b:	c7 05 48 0a 00 00 00 	movl   $0x0,0xa48
 732:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 735:	8b 45 f0             	mov    -0x10(%ebp),%eax
 738:	8b 00                	mov    (%eax),%eax
 73a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 740:	8b 40 04             	mov    0x4(%eax),%eax
 743:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 746:	72 4d                	jb     795 <malloc+0xa4>
      if(p->s.size == nunits)
 748:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74b:	8b 40 04             	mov    0x4(%eax),%eax
 74e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 751:	75 0c                	jne    75f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 753:	8b 45 f4             	mov    -0xc(%ebp),%eax
 756:	8b 10                	mov    (%eax),%edx
 758:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75b:	89 10                	mov    %edx,(%eax)
 75d:	eb 26                	jmp    785 <malloc+0x94>
      else {
        p->s.size -= nunits;
 75f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 762:	8b 40 04             	mov    0x4(%eax),%eax
 765:	89 c2                	mov    %eax,%edx
 767:	2b 55 ec             	sub    -0x14(%ebp),%edx
 76a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 770:	8b 45 f4             	mov    -0xc(%ebp),%eax
 773:	8b 40 04             	mov    0x4(%eax),%eax
 776:	c1 e0 03             	shl    $0x3,%eax
 779:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 77c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 782:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 785:	8b 45 f0             	mov    -0x10(%ebp),%eax
 788:	a3 4c 0a 00 00       	mov    %eax,0xa4c
      return (void*)(p + 1);
 78d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 790:	83 c0 08             	add    $0x8,%eax
 793:	eb 38                	jmp    7cd <malloc+0xdc>
    }
    if(p == freep)
 795:	a1 4c 0a 00 00       	mov    0xa4c,%eax
 79a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 79d:	75 1b                	jne    7ba <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 79f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7a2:	89 04 24             	mov    %eax,(%esp)
 7a5:	e8 ef fe ff ff       	call   699 <morecore>
 7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7ad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b1:	75 07                	jne    7ba <malloc+0xc9>
        return 0;
 7b3:	b8 00 00 00 00       	mov    $0x0,%eax
 7b8:	eb 13                	jmp    7cd <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	8b 00                	mov    (%eax),%eax
 7c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7c8:	e9 70 ff ff ff       	jmp    73d <malloc+0x4c>
}
 7cd:	c9                   	leave  
 7ce:	c3                   	ret    
