
_signal_handler:     file format elf32-i386


Disassembly of section .text:

00000000 <custom_sighandler>:
#include "types.h"
#include "user.h"

void custom_sighandler(int signum)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 28             	sub    $0x28,%esp
    printf(1, "User-defined handler called!\n");
   6:	c7 44 24 04 b7 08 00 	movl   $0x8b7,0x4(%esp)
   d:	00 
   e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  15:	e8 d6 04 00 00       	call   4f0 <printf>
    static int i = 0;
    int *ret = &i;
  1a:	c7 45 f4 68 0b 00 00 	movl   $0xb68,-0xc(%ebp)
    i++;
  21:	a1 68 0b 00 00       	mov    0xb68,%eax
  26:	40                   	inc    %eax
  27:	a3 68 0b 00 00       	mov    %eax,0xb68
    
    if(i == 100)
  2c:	a1 68 0b 00 00       	mov    0xb68,%eax
  31:	83 f8 64             	cmp    $0x64,%eax
  34:	75 31                	jne    67 <custom_sighandler+0x67>
    {
        ret += 55;
  36:	81 45 f4 dc 00 00 00 	addl   $0xdc,-0xc(%ebp)
        (*ret) = (*ret) + 8;
  3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  40:	8b 00                	mov    (%eax),%eax
  42:	8d 50 08             	lea    0x8(%eax),%edx
  45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  48:	89 10                	mov    %edx,(%eax)
        printf(1, "%x", *ret);
  4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4d:	8b 00                	mov    (%eax),%eax
  4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  53:	c7 44 24 04 d5 08 00 	movl   $0x8d5,0x4(%esp)
  5a:	00 
  5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  62:	e8 89 04 00 00       	call   4f0 <printf>
    }
}
  67:	c9                   	leave  
  68:	c3                   	ret    

00000069 <main>:

int main(void)
{
  69:	55                   	push   %ebp
  6a:	89 e5                	mov    %esp,%ebp
  6c:	83 e4 f0             	and    $0xfffffff0,%esp
  6f:	83 ec 20             	sub    $0x20,%esp
    int i = signal(SIGSEGV, custom_sighandler);
  72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  79:	00 
  7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  81:	e8 8a 03 00 00       	call   410 <signal>
  86:	89 44 24 14          	mov    %eax,0x14(%esp)
    int *ptr = &i;
  8a:	8d 44 24 14          	lea    0x14(%esp),%eax
  8e:	89 44 24 1c          	mov    %eax,0x1c(%esp)

    ptr += 50000;
  92:	81 44 24 1c 40 0d 03 	addl   $0x30d40,0x1c(%esp)
  99:	00 

    int t = uptime();
  9a:	e8 59 03 00 00       	call   3f8 <uptime>
  9f:	89 44 24 18          	mov    %eax,0x18(%esp)
    printf(1, "%d\n", *ptr);
  a3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  a7:	8b 00                	mov    (%eax),%eax
  a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  ad:	c7 44 24 04 d8 08 00 	movl   $0x8d8,0x4(%esp)
  b4:	00 
  b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  bc:	e8 2f 04 00 00       	call   4f0 <printf>
    printf(1, "Crossed Exception\n");
  c1:	c7 44 24 04 dc 08 00 	movl   $0x8dc,0x4(%esp)
  c8:	00 
  c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d0:	e8 1b 04 00 00       	call   4f0 <printf>
    printf(1, "%d\n", (t - uptime())/100);
  d5:	e8 1e 03 00 00       	call   3f8 <uptime>
  da:	8b 54 24 18          	mov    0x18(%esp),%edx
  de:	89 d1                	mov    %edx,%ecx
  e0:	29 c1                	sub    %eax,%ecx
  e2:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
  e7:	f7 e9                	imul   %ecx
  e9:	c1 fa 05             	sar    $0x5,%edx
  ec:	89 c8                	mov    %ecx,%eax
  ee:	c1 f8 1f             	sar    $0x1f,%eax
  f1:	89 d1                	mov    %edx,%ecx
  f3:	29 c1                	sub    %eax,%ecx
  f5:	89 c8                	mov    %ecx,%eax
  f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  fb:	c7 44 24 04 d8 08 00 	movl   $0x8d8,0x4(%esp)
 102:	00 
 103:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 10a:	e8 e1 03 00 00       	call   4f0 <printf>

    exit();
 10f:	e8 4c 02 00 00       	call   360 <exit>

00000114 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	57                   	push   %edi
 118:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 119:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11c:	8b 55 10             	mov    0x10(%ebp),%edx
 11f:	8b 45 0c             	mov    0xc(%ebp),%eax
 122:	89 cb                	mov    %ecx,%ebx
 124:	89 df                	mov    %ebx,%edi
 126:	89 d1                	mov    %edx,%ecx
 128:	fc                   	cld    
 129:	f3 aa                	rep stos %al,%es:(%edi)
 12b:	89 ca                	mov    %ecx,%edx
 12d:	89 fb                	mov    %edi,%ebx
 12f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 132:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 135:	5b                   	pop    %ebx
 136:	5f                   	pop    %edi
 137:	5d                   	pop    %ebp
 138:	c3                   	ret    

00000139 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 145:	90                   	nop
 146:	8b 45 0c             	mov    0xc(%ebp),%eax
 149:	8a 10                	mov    (%eax),%dl
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	88 10                	mov    %dl,(%eax)
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	8a 00                	mov    (%eax),%al
 155:	84 c0                	test   %al,%al
 157:	0f 95 c0             	setne  %al
 15a:	ff 45 08             	incl   0x8(%ebp)
 15d:	ff 45 0c             	incl   0xc(%ebp)
 160:	84 c0                	test   %al,%al
 162:	75 e2                	jne    146 <strcpy+0xd>
    ;
  return os;
 164:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 167:	c9                   	leave  
 168:	c3                   	ret    

00000169 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 169:	55                   	push   %ebp
 16a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 16c:	eb 06                	jmp    174 <strcmp+0xb>
    p++, q++;
 16e:	ff 45 08             	incl   0x8(%ebp)
 171:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	8a 00                	mov    (%eax),%al
 179:	84 c0                	test   %al,%al
 17b:	74 0e                	je     18b <strcmp+0x22>
 17d:	8b 45 08             	mov    0x8(%ebp),%eax
 180:	8a 10                	mov    (%eax),%dl
 182:	8b 45 0c             	mov    0xc(%ebp),%eax
 185:	8a 00                	mov    (%eax),%al
 187:	38 c2                	cmp    %al,%dl
 189:	74 e3                	je     16e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	8a 00                	mov    (%eax),%al
 190:	0f b6 d0             	movzbl %al,%edx
 193:	8b 45 0c             	mov    0xc(%ebp),%eax
 196:	8a 00                	mov    (%eax),%al
 198:	0f b6 c0             	movzbl %al,%eax
 19b:	89 d1                	mov    %edx,%ecx
 19d:	29 c1                	sub    %eax,%ecx
 19f:	89 c8                	mov    %ecx,%eax
}
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <strlen>:

uint
strlen(char *s)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b0:	eb 03                	jmp    1b5 <strlen+0x12>
 1b2:	ff 45 fc             	incl   -0x4(%ebp)
 1b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	01 d0                	add    %edx,%eax
 1bd:	8a 00                	mov    (%eax),%al
 1bf:	84 c0                	test   %al,%al
 1c1:	75 ef                	jne    1b2 <strlen+0xf>
    ;
  return n;
 1c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c6:	c9                   	leave  
 1c7:	c3                   	ret    

000001c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c8:	55                   	push   %ebp
 1c9:	89 e5                	mov    %esp,%ebp
 1cb:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1ce:	8b 45 10             	mov    0x10(%ebp),%eax
 1d1:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1dc:	8b 45 08             	mov    0x8(%ebp),%eax
 1df:	89 04 24             	mov    %eax,(%esp)
 1e2:	e8 2d ff ff ff       	call   114 <stosb>
  return dst;
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ea:	c9                   	leave  
 1eb:	c3                   	ret    

000001ec <strchr>:

char*
strchr(const char *s, char c)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	83 ec 04             	sub    $0x4,%esp
 1f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f8:	eb 12                	jmp    20c <strchr+0x20>
    if(*s == c)
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
 1fd:	8a 00                	mov    (%eax),%al
 1ff:	3a 45 fc             	cmp    -0x4(%ebp),%al
 202:	75 05                	jne    209 <strchr+0x1d>
      return (char*)s;
 204:	8b 45 08             	mov    0x8(%ebp),%eax
 207:	eb 11                	jmp    21a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 209:	ff 45 08             	incl   0x8(%ebp)
 20c:	8b 45 08             	mov    0x8(%ebp),%eax
 20f:	8a 00                	mov    (%eax),%al
 211:	84 c0                	test   %al,%al
 213:	75 e5                	jne    1fa <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 215:	b8 00 00 00 00       	mov    $0x0,%eax
}
 21a:	c9                   	leave  
 21b:	c3                   	ret    

0000021c <gets>:

char*
gets(char *buf, int max)
{
 21c:	55                   	push   %ebp
 21d:	89 e5                	mov    %esp,%ebp
 21f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 222:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 229:	eb 42                	jmp    26d <gets+0x51>
    cc = read(0, &c, 1);
 22b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 232:	00 
 233:	8d 45 ef             	lea    -0x11(%ebp),%eax
 236:	89 44 24 04          	mov    %eax,0x4(%esp)
 23a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 241:	e8 32 01 00 00       	call   378 <read>
 246:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 249:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 24d:	7e 29                	jle    278 <gets+0x5c>
      break;
    buf[i++] = c;
 24f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 252:	8b 45 08             	mov    0x8(%ebp),%eax
 255:	01 c2                	add    %eax,%edx
 257:	8a 45 ef             	mov    -0x11(%ebp),%al
 25a:	88 02                	mov    %al,(%edx)
 25c:	ff 45 f4             	incl   -0xc(%ebp)
    if(c == '\n' || c == '\r')
 25f:	8a 45 ef             	mov    -0x11(%ebp),%al
 262:	3c 0a                	cmp    $0xa,%al
 264:	74 13                	je     279 <gets+0x5d>
 266:	8a 45 ef             	mov    -0x11(%ebp),%al
 269:	3c 0d                	cmp    $0xd,%al
 26b:	74 0c                	je     279 <gets+0x5d>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 270:	40                   	inc    %eax
 271:	3b 45 0c             	cmp    0xc(%ebp),%eax
 274:	7c b5                	jl     22b <gets+0xf>
 276:	eb 01                	jmp    279 <gets+0x5d>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 278:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 279:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	01 d0                	add    %edx,%eax
 281:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 284:	8b 45 08             	mov    0x8(%ebp),%eax
}
 287:	c9                   	leave  
 288:	c3                   	ret    

00000289 <stat>:

int
stat(char *n, struct stat *st)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 296:	00 
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 fe 00 00 00       	call   3a0 <open>
 2a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a9:	79 07                	jns    2b2 <stat+0x29>
    return -1;
 2ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b0:	eb 23                	jmp    2d5 <stat+0x4c>
  r = fstat(fd, st);
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bc:	89 04 24             	mov    %eax,(%esp)
 2bf:	e8 f4 00 00 00       	call   3b8 <fstat>
 2c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	89 04 24             	mov    %eax,(%esp)
 2cd:	e8 b6 00 00 00       	call   388 <close>
  return r;
 2d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d5:	c9                   	leave  
 2d6:	c3                   	ret    

000002d7 <atoi>:

int
atoi(const char *s)
{
 2d7:	55                   	push   %ebp
 2d8:	89 e5                	mov    %esp,%ebp
 2da:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e4:	eb 21                	jmp    307 <atoi+0x30>
    n = n*10 + *s++ - '0';
 2e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e9:	89 d0                	mov    %edx,%eax
 2eb:	c1 e0 02             	shl    $0x2,%eax
 2ee:	01 d0                	add    %edx,%eax
 2f0:	d1 e0                	shl    %eax
 2f2:	89 c2                	mov    %eax,%edx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	8a 00                	mov    (%eax),%al
 2f9:	0f be c0             	movsbl %al,%eax
 2fc:	01 d0                	add    %edx,%eax
 2fe:	83 e8 30             	sub    $0x30,%eax
 301:	89 45 fc             	mov    %eax,-0x4(%ebp)
 304:	ff 45 08             	incl   0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	8a 00                	mov    (%eax),%al
 30c:	3c 2f                	cmp    $0x2f,%al
 30e:	7e 09                	jle    319 <atoi+0x42>
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	8a 00                	mov    (%eax),%al
 315:	3c 39                	cmp    $0x39,%al
 317:	7e cd                	jle    2e6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 319:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31c:	c9                   	leave  
 31d:	c3                   	ret    

0000031e <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 31e:	55                   	push   %ebp
 31f:	89 e5                	mov    %esp,%ebp
 321:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 324:	8b 45 08             	mov    0x8(%ebp),%eax
 327:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 32a:	8b 45 0c             	mov    0xc(%ebp),%eax
 32d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 330:	eb 10                	jmp    342 <memmove+0x24>
    *dst++ = *src++;
 332:	8b 45 f8             	mov    -0x8(%ebp),%eax
 335:	8a 10                	mov    (%eax),%dl
 337:	8b 45 fc             	mov    -0x4(%ebp),%eax
 33a:	88 10                	mov    %dl,(%eax)
 33c:	ff 45 fc             	incl   -0x4(%ebp)
 33f:	ff 45 f8             	incl   -0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 342:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 346:	0f 9f c0             	setg   %al
 349:	ff 4d 10             	decl   0x10(%ebp)
 34c:	84 c0                	test   %al,%al
 34e:	75 e2                	jne    332 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 350:	8b 45 08             	mov    0x8(%ebp),%eax
}
 353:	c9                   	leave  
 354:	c3                   	ret    
 355:	66 90                	xchg   %ax,%ax
 357:	90                   	nop

00000358 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 358:	b8 01 00 00 00       	mov    $0x1,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <exit>:
SYSCALL(exit)
 360:	b8 02 00 00 00       	mov    $0x2,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <wait>:
SYSCALL(wait)
 368:	b8 03 00 00 00       	mov    $0x3,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <pipe>:
SYSCALL(pipe)
 370:	b8 04 00 00 00       	mov    $0x4,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <read>:
SYSCALL(read)
 378:	b8 05 00 00 00       	mov    $0x5,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <write>:
SYSCALL(write)
 380:	b8 10 00 00 00       	mov    $0x10,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <close>:
SYSCALL(close)
 388:	b8 15 00 00 00       	mov    $0x15,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <kill>:
SYSCALL(kill)
 390:	b8 06 00 00 00       	mov    $0x6,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <exec>:
SYSCALL(exec)
 398:	b8 07 00 00 00       	mov    $0x7,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <open>:
SYSCALL(open)
 3a0:	b8 0f 00 00 00       	mov    $0xf,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <mknod>:
SYSCALL(mknod)
 3a8:	b8 11 00 00 00       	mov    $0x11,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <unlink>:
SYSCALL(unlink)
 3b0:	b8 12 00 00 00       	mov    $0x12,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <fstat>:
SYSCALL(fstat)
 3b8:	b8 08 00 00 00       	mov    $0x8,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <link>:
SYSCALL(link)
 3c0:	b8 13 00 00 00       	mov    $0x13,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <mkdir>:
SYSCALL(mkdir)
 3c8:	b8 14 00 00 00       	mov    $0x14,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <chdir>:
SYSCALL(chdir)
 3d0:	b8 09 00 00 00       	mov    $0x9,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <dup>:
SYSCALL(dup)
 3d8:	b8 0a 00 00 00       	mov    $0xa,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <getpid>:
SYSCALL(getpid)
 3e0:	b8 0b 00 00 00       	mov    $0xb,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <sbrk>:
SYSCALL(sbrk)
 3e8:	b8 0c 00 00 00       	mov    $0xc,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <sleep>:
SYSCALL(sleep)
 3f0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <uptime>:
SYSCALL(uptime)
 3f8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <getppid>:
SYSCALL(getppid)        // USER DEFINED SYS CALL
 400:	b8 16 00 00 00       	mov    $0x16,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <icount>:
SYSCALL(icount)         // USER DEFINED SYS CALL
 408:	b8 17 00 00 00       	mov    $0x17,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <signal>:
SYSCALL(signal)         // USER DEFINED SYS CALL
 410:	b8 18 00 00 00       	mov    $0x18,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 418:	55                   	push   %ebp
 419:	89 e5                	mov    %esp,%ebp
 41b:	83 ec 28             	sub    $0x28,%esp
 41e:	8b 45 0c             	mov    0xc(%ebp),%eax
 421:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 424:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 42b:	00 
 42c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 42f:	89 44 24 04          	mov    %eax,0x4(%esp)
 433:	8b 45 08             	mov    0x8(%ebp),%eax
 436:	89 04 24             	mov    %eax,(%esp)
 439:	e8 42 ff ff ff       	call   380 <write>
}
 43e:	c9                   	leave  
 43f:	c3                   	ret    

00000440 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 440:	55                   	push   %ebp
 441:	89 e5                	mov    %esp,%ebp
 443:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 446:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 44d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 451:	74 17                	je     46a <printint+0x2a>
 453:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 457:	79 11                	jns    46a <printint+0x2a>
    neg = 1;
 459:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 460:	8b 45 0c             	mov    0xc(%ebp),%eax
 463:	f7 d8                	neg    %eax
 465:	89 45 ec             	mov    %eax,-0x14(%ebp)
 468:	eb 06                	jmp    470 <printint+0x30>
  } else {
    x = xx;
 46a:	8b 45 0c             	mov    0xc(%ebp),%eax
 46d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 470:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 477:	8b 4d 10             	mov    0x10(%ebp),%ecx
 47a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 47d:	ba 00 00 00 00       	mov    $0x0,%edx
 482:	f7 f1                	div    %ecx
 484:	89 d0                	mov    %edx,%eax
 486:	8a 80 54 0b 00 00    	mov    0xb54(%eax),%al
 48c:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 48f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 492:	01 ca                	add    %ecx,%edx
 494:	88 02                	mov    %al,(%edx)
 496:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
 499:	8b 55 10             	mov    0x10(%ebp),%edx
 49c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 49f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a2:	ba 00 00 00 00       	mov    $0x0,%edx
 4a7:	f7 75 d4             	divl   -0x2c(%ebp)
 4aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b1:	75 c4                	jne    477 <printint+0x37>
  if(neg)
 4b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4b7:	74 2c                	je     4e5 <printint+0xa5>
    buf[i++] = '-';
 4b9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4bf:	01 d0                	add    %edx,%eax
 4c1:	c6 00 2d             	movb   $0x2d,(%eax)
 4c4:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
 4c7:	eb 1c                	jmp    4e5 <printint+0xa5>
    putc(fd, buf[i]);
 4c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4cf:	01 d0                	add    %edx,%eax
 4d1:	8a 00                	mov    (%eax),%al
 4d3:	0f be c0             	movsbl %al,%eax
 4d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
 4dd:	89 04 24             	mov    %eax,(%esp)
 4e0:	e8 33 ff ff ff       	call   418 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4e5:	ff 4d f4             	decl   -0xc(%ebp)
 4e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4ec:	79 db                	jns    4c9 <printint+0x89>
    putc(fd, buf[i]);
}
 4ee:	c9                   	leave  
 4ef:	c3                   	ret    

000004f0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4f0:	55                   	push   %ebp
 4f1:	89 e5                	mov    %esp,%ebp
 4f3:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4f6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4fd:	8d 45 0c             	lea    0xc(%ebp),%eax
 500:	83 c0 04             	add    $0x4,%eax
 503:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 506:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 50d:	e9 78 01 00 00       	jmp    68a <printf+0x19a>
    c = fmt[i] & 0xff;
 512:	8b 55 0c             	mov    0xc(%ebp),%edx
 515:	8b 45 f0             	mov    -0x10(%ebp),%eax
 518:	01 d0                	add    %edx,%eax
 51a:	8a 00                	mov    (%eax),%al
 51c:	0f be c0             	movsbl %al,%eax
 51f:	25 ff 00 00 00       	and    $0xff,%eax
 524:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 527:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 52b:	75 2c                	jne    559 <printf+0x69>
      if(c == '%'){
 52d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 531:	75 0c                	jne    53f <printf+0x4f>
        state = '%';
 533:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 53a:	e9 48 01 00 00       	jmp    687 <printf+0x197>
      } else {
        putc(fd, c);
 53f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 542:	0f be c0             	movsbl %al,%eax
 545:	89 44 24 04          	mov    %eax,0x4(%esp)
 549:	8b 45 08             	mov    0x8(%ebp),%eax
 54c:	89 04 24             	mov    %eax,(%esp)
 54f:	e8 c4 fe ff ff       	call   418 <putc>
 554:	e9 2e 01 00 00       	jmp    687 <printf+0x197>
      }
    } else if(state == '%'){
 559:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 55d:	0f 85 24 01 00 00    	jne    687 <printf+0x197>
      if(c == 'd'){
 563:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 567:	75 2d                	jne    596 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 569:	8b 45 e8             	mov    -0x18(%ebp),%eax
 56c:	8b 00                	mov    (%eax),%eax
 56e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 575:	00 
 576:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 57d:	00 
 57e:	89 44 24 04          	mov    %eax,0x4(%esp)
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	89 04 24             	mov    %eax,(%esp)
 588:	e8 b3 fe ff ff       	call   440 <printint>
        ap++;
 58d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 591:	e9 ea 00 00 00       	jmp    680 <printf+0x190>
      } else if(c == 'x' || c == 'p'){
 596:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 59a:	74 06                	je     5a2 <printf+0xb2>
 59c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5a0:	75 2d                	jne    5cf <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a5:	8b 00                	mov    (%eax),%eax
 5a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5ae:	00 
 5af:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5b6:	00 
 5b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 5bb:	8b 45 08             	mov    0x8(%ebp),%eax
 5be:	89 04 24             	mov    %eax,(%esp)
 5c1:	e8 7a fe ff ff       	call   440 <printint>
        ap++;
 5c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5ca:	e9 b1 00 00 00       	jmp    680 <printf+0x190>
      } else if(c == 's'){
 5cf:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5d3:	75 43                	jne    618 <printf+0x128>
        s = (char*)*ap;
 5d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5d8:	8b 00                	mov    (%eax),%eax
 5da:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5dd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5e1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5e5:	75 25                	jne    60c <printf+0x11c>
          s = "(null)";
 5e7:	c7 45 f4 ef 08 00 00 	movl   $0x8ef,-0xc(%ebp)
        while(*s != 0){
 5ee:	eb 1c                	jmp    60c <printf+0x11c>
          putc(fd, *s);
 5f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5f3:	8a 00                	mov    (%eax),%al
 5f5:	0f be c0             	movsbl %al,%eax
 5f8:	89 44 24 04          	mov    %eax,0x4(%esp)
 5fc:	8b 45 08             	mov    0x8(%ebp),%eax
 5ff:	89 04 24             	mov    %eax,(%esp)
 602:	e8 11 fe ff ff       	call   418 <putc>
          s++;
 607:	ff 45 f4             	incl   -0xc(%ebp)
 60a:	eb 01                	jmp    60d <printf+0x11d>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 60c:	90                   	nop
 60d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 610:	8a 00                	mov    (%eax),%al
 612:	84 c0                	test   %al,%al
 614:	75 da                	jne    5f0 <printf+0x100>
 616:	eb 68                	jmp    680 <printf+0x190>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 618:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 61c:	75 1d                	jne    63b <printf+0x14b>
        putc(fd, *ap);
 61e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 621:	8b 00                	mov    (%eax),%eax
 623:	0f be c0             	movsbl %al,%eax
 626:	89 44 24 04          	mov    %eax,0x4(%esp)
 62a:	8b 45 08             	mov    0x8(%ebp),%eax
 62d:	89 04 24             	mov    %eax,(%esp)
 630:	e8 e3 fd ff ff       	call   418 <putc>
        ap++;
 635:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 639:	eb 45                	jmp    680 <printf+0x190>
      } else if(c == '%'){
 63b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 63f:	75 17                	jne    658 <printf+0x168>
        putc(fd, c);
 641:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 644:	0f be c0             	movsbl %al,%eax
 647:	89 44 24 04          	mov    %eax,0x4(%esp)
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	89 04 24             	mov    %eax,(%esp)
 651:	e8 c2 fd ff ff       	call   418 <putc>
 656:	eb 28                	jmp    680 <printf+0x190>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 658:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 65f:	00 
 660:	8b 45 08             	mov    0x8(%ebp),%eax
 663:	89 04 24             	mov    %eax,(%esp)
 666:	e8 ad fd ff ff       	call   418 <putc>
        putc(fd, c);
 66b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 66e:	0f be c0             	movsbl %al,%eax
 671:	89 44 24 04          	mov    %eax,0x4(%esp)
 675:	8b 45 08             	mov    0x8(%ebp),%eax
 678:	89 04 24             	mov    %eax,(%esp)
 67b:	e8 98 fd ff ff       	call   418 <putc>
      }
      state = 0;
 680:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 687:	ff 45 f0             	incl   -0x10(%ebp)
 68a:	8b 55 0c             	mov    0xc(%ebp),%edx
 68d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 690:	01 d0                	add    %edx,%eax
 692:	8a 00                	mov    (%eax),%al
 694:	84 c0                	test   %al,%al
 696:	0f 85 76 fe ff ff    	jne    512 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 69c:	c9                   	leave  
 69d:	c3                   	ret    
 69e:	66 90                	xchg   %ax,%ax

000006a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a0:	55                   	push   %ebp
 6a1:	89 e5                	mov    %esp,%ebp
 6a3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a6:	8b 45 08             	mov    0x8(%ebp),%eax
 6a9:	83 e8 08             	sub    $0x8,%eax
 6ac:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6af:	a1 74 0b 00 00       	mov    0xb74,%eax
 6b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6b7:	eb 24                	jmp    6dd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bc:	8b 00                	mov    (%eax),%eax
 6be:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c1:	77 12                	ja     6d5 <free+0x35>
 6c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6c9:	77 24                	ja     6ef <free+0x4f>
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	8b 00                	mov    (%eax),%eax
 6d0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6d3:	77 1a                	ja     6ef <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 00                	mov    (%eax),%eax
 6da:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6e3:	76 d4                	jbe    6b9 <free+0x19>
 6e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e8:	8b 00                	mov    (%eax),%eax
 6ea:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6ed:	76 ca                	jbe    6b9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 6ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f2:	8b 40 04             	mov    0x4(%eax),%eax
 6f5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ff:	01 c2                	add    %eax,%edx
 701:	8b 45 fc             	mov    -0x4(%ebp),%eax
 704:	8b 00                	mov    (%eax),%eax
 706:	39 c2                	cmp    %eax,%edx
 708:	75 24                	jne    72e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 70a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 70d:	8b 50 04             	mov    0x4(%eax),%edx
 710:	8b 45 fc             	mov    -0x4(%ebp),%eax
 713:	8b 00                	mov    (%eax),%eax
 715:	8b 40 04             	mov    0x4(%eax),%eax
 718:	01 c2                	add    %eax,%edx
 71a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 71d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 720:	8b 45 fc             	mov    -0x4(%ebp),%eax
 723:	8b 00                	mov    (%eax),%eax
 725:	8b 10                	mov    (%eax),%edx
 727:	8b 45 f8             	mov    -0x8(%ebp),%eax
 72a:	89 10                	mov    %edx,(%eax)
 72c:	eb 0a                	jmp    738 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 72e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 731:	8b 10                	mov    (%eax),%edx
 733:	8b 45 f8             	mov    -0x8(%ebp),%eax
 736:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 738:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73b:	8b 40 04             	mov    0x4(%eax),%eax
 73e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 745:	8b 45 fc             	mov    -0x4(%ebp),%eax
 748:	01 d0                	add    %edx,%eax
 74a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 74d:	75 20                	jne    76f <free+0xcf>
    p->s.size += bp->s.size;
 74f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 752:	8b 50 04             	mov    0x4(%eax),%edx
 755:	8b 45 f8             	mov    -0x8(%ebp),%eax
 758:	8b 40 04             	mov    0x4(%eax),%eax
 75b:	01 c2                	add    %eax,%edx
 75d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 760:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 763:	8b 45 f8             	mov    -0x8(%ebp),%eax
 766:	8b 10                	mov    (%eax),%edx
 768:	8b 45 fc             	mov    -0x4(%ebp),%eax
 76b:	89 10                	mov    %edx,(%eax)
 76d:	eb 08                	jmp    777 <free+0xd7>
  } else
    p->s.ptr = bp;
 76f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 772:	8b 55 f8             	mov    -0x8(%ebp),%edx
 775:	89 10                	mov    %edx,(%eax)
  freep = p;
 777:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77a:	a3 74 0b 00 00       	mov    %eax,0xb74
}
 77f:	c9                   	leave  
 780:	c3                   	ret    

00000781 <morecore>:

static Header*
morecore(uint nu)
{
 781:	55                   	push   %ebp
 782:	89 e5                	mov    %esp,%ebp
 784:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 787:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 78e:	77 07                	ja     797 <morecore+0x16>
    nu = 4096;
 790:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 797:	8b 45 08             	mov    0x8(%ebp),%eax
 79a:	c1 e0 03             	shl    $0x3,%eax
 79d:	89 04 24             	mov    %eax,(%esp)
 7a0:	e8 43 fc ff ff       	call   3e8 <sbrk>
 7a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7a8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7ac:	75 07                	jne    7b5 <morecore+0x34>
    return 0;
 7ae:	b8 00 00 00 00       	mov    $0x0,%eax
 7b3:	eb 22                	jmp    7d7 <morecore+0x56>
  hp = (Header*)p;
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7be:	8b 55 08             	mov    0x8(%ebp),%edx
 7c1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7c7:	83 c0 08             	add    $0x8,%eax
 7ca:	89 04 24             	mov    %eax,(%esp)
 7cd:	e8 ce fe ff ff       	call   6a0 <free>
  return freep;
 7d2:	a1 74 0b 00 00       	mov    0xb74,%eax
}
 7d7:	c9                   	leave  
 7d8:	c3                   	ret    

000007d9 <malloc>:

void*
malloc(uint nbytes)
{
 7d9:	55                   	push   %ebp
 7da:	89 e5                	mov    %esp,%ebp
 7dc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7df:	8b 45 08             	mov    0x8(%ebp),%eax
 7e2:	83 c0 07             	add    $0x7,%eax
 7e5:	c1 e8 03             	shr    $0x3,%eax
 7e8:	40                   	inc    %eax
 7e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7ec:	a1 74 0b 00 00       	mov    0xb74,%eax
 7f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7f8:	75 23                	jne    81d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 7fa:	c7 45 f0 6c 0b 00 00 	movl   $0xb6c,-0x10(%ebp)
 801:	8b 45 f0             	mov    -0x10(%ebp),%eax
 804:	a3 74 0b 00 00       	mov    %eax,0xb74
 809:	a1 74 0b 00 00       	mov    0xb74,%eax
 80e:	a3 6c 0b 00 00       	mov    %eax,0xb6c
    base.s.size = 0;
 813:	c7 05 70 0b 00 00 00 	movl   $0x0,0xb70
 81a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 820:	8b 00                	mov    (%eax),%eax
 822:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 825:	8b 45 f4             	mov    -0xc(%ebp),%eax
 828:	8b 40 04             	mov    0x4(%eax),%eax
 82b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 82e:	72 4d                	jb     87d <malloc+0xa4>
      if(p->s.size == nunits)
 830:	8b 45 f4             	mov    -0xc(%ebp),%eax
 833:	8b 40 04             	mov    0x4(%eax),%eax
 836:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 839:	75 0c                	jne    847 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 83b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83e:	8b 10                	mov    (%eax),%edx
 840:	8b 45 f0             	mov    -0x10(%ebp),%eax
 843:	89 10                	mov    %edx,(%eax)
 845:	eb 26                	jmp    86d <malloc+0x94>
      else {
        p->s.size -= nunits;
 847:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84a:	8b 40 04             	mov    0x4(%eax),%eax
 84d:	89 c2                	mov    %eax,%edx
 84f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 852:	8b 45 f4             	mov    -0xc(%ebp),%eax
 855:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 858:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85b:	8b 40 04             	mov    0x4(%eax),%eax
 85e:	c1 e0 03             	shl    $0x3,%eax
 861:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 864:	8b 45 f4             	mov    -0xc(%ebp),%eax
 867:	8b 55 ec             	mov    -0x14(%ebp),%edx
 86a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 86d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 870:	a3 74 0b 00 00       	mov    %eax,0xb74
      return (void*)(p + 1);
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	83 c0 08             	add    $0x8,%eax
 87b:	eb 38                	jmp    8b5 <malloc+0xdc>
    }
    if(p == freep)
 87d:	a1 74 0b 00 00       	mov    0xb74,%eax
 882:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 885:	75 1b                	jne    8a2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 887:	8b 45 ec             	mov    -0x14(%ebp),%eax
 88a:	89 04 24             	mov    %eax,(%esp)
 88d:	e8 ef fe ff ff       	call   781 <morecore>
 892:	89 45 f4             	mov    %eax,-0xc(%ebp)
 895:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 899:	75 07                	jne    8a2 <malloc+0xc9>
        return 0;
 89b:	b8 00 00 00 00       	mov    $0x0,%eax
 8a0:	eb 13                	jmp    8b5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ab:	8b 00                	mov    (%eax),%eax
 8ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8b0:	e9 70 ff ff ff       	jmp    825 <malloc+0x4c>
}
 8b5:	c9                   	leave  
 8b6:	c3                   	ret    
