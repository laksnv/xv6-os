
_wc:     file format elf32-i386


Disassembly of section .text:

00000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 48             	sub    $0x48,%esp
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
   6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
   d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  13:	8b 45 ec             	mov    -0x14(%ebp),%eax
  16:	89 45 f0             	mov    %eax,-0x10(%ebp)
  inword = 0;
  19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
  20:	eb 62                	jmp    84 <wc+0x84>
    for(i=0; i<n; i++){
  22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  29:	eb 51                	jmp    7c <wc+0x7c>
      c++;
  2b:	ff 45 e8             	incl   -0x18(%ebp)
      if(buf[i] == '\n')
  2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  31:	05 60 0c 00 00       	add    $0xc60,%eax
  36:	8a 00                	mov    (%eax),%al
  38:	3c 0a                	cmp    $0xa,%al
  3a:	75 03                	jne    3f <wc+0x3f>
        l++;
  3c:	ff 45 f0             	incl   -0x10(%ebp)
      if(strchr(" \r\t\n\v", buf[i]))
  3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  42:	05 60 0c 00 00       	add    $0xc60,%eax
  47:	8a 00                	mov    (%eax),%al
  49:	0f be c0             	movsbl %al,%eax
  4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  50:	c7 04 24 77 09 00 00 	movl   $0x977,(%esp)
  57:	e8 50 02 00 00       	call   2ac <strchr>
  5c:	85 c0                	test   %eax,%eax
  5e:	74 09                	je     69 <wc+0x69>
        inword = 0;
  60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  67:	eb 10                	jmp    79 <wc+0x79>
      else if(!inword){
  69:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  6d:	75 0a                	jne    79 <wc+0x79>
        w++;
  6f:	ff 45 ec             	incl   -0x14(%ebp)
        inword = 1;
  72:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
  79:	ff 45 f4             	incl   -0xc(%ebp)
  7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  7f:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  82:	7c a7                	jl     2b <wc+0x2b>
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
  84:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8b:	00 
  8c:	c7 44 24 04 60 0c 00 	movl   $0xc60,0x4(%esp)
  93:	00 
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	89 04 24             	mov    %eax,(%esp)
  9a:	e8 99 03 00 00       	call   438 <read>
  9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  a6:	0f 8f 76 ff ff ff    	jg     22 <wc+0x22>
        w++;
        inword = 1;
      }
    }
  }
  if(n < 0){
  ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  b0:	79 19                	jns    cb <wc+0xcb>
    printf(1, "wc: read error\n");
  b2:	c7 44 24 04 7d 09 00 	movl   $0x97d,0x4(%esp)
  b9:	00 
  ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  c1:	e8 ea 04 00 00       	call   5b0 <printf>
    exit();
  c6:	e8 55 03 00 00       	call   420 <exit>
  }
  printf(1, "%d %d %d %s\n", l, w, c, name);
  cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  ce:	89 44 24 14          	mov    %eax,0x14(%esp)
  d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  e7:	c7 44 24 04 8d 09 00 	movl   $0x98d,0x4(%esp)
  ee:	00 
  ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  f6:	e8 b5 04 00 00       	call   5b0 <printf>
}
  fb:	c9                   	leave  
  fc:	c3                   	ret    

000000fd <main>:

int
main(int argc, char *argv[])
{
  fd:	55                   	push   %ebp
  fe:	89 e5                	mov    %esp,%ebp
 100:	83 e4 f0             	and    $0xfffffff0,%esp
 103:	83 ec 20             	sub    $0x20,%esp
  int fd, i;

  if(argc <= 1){
 106:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 10a:	7f 19                	jg     125 <main+0x28>
    wc(0, "");
 10c:	c7 44 24 04 9a 09 00 	movl   $0x99a,0x4(%esp)
 113:	00 
 114:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 11b:	e8 e0 fe ff ff       	call   0 <wc>
    exit();
 120:	e8 fb 02 00 00       	call   420 <exit>
  }

  for(i = 1; i < argc; i++){
 125:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 12c:	00 
 12d:	e9 8e 00 00 00       	jmp    1c0 <main+0xc3>
    if((fd = open(argv[i], 0)) < 0){
 132:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 136:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 13d:	8b 45 0c             	mov    0xc(%ebp),%eax
 140:	01 d0                	add    %edx,%eax
 142:	8b 00                	mov    (%eax),%eax
 144:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 14b:	00 
 14c:	89 04 24             	mov    %eax,(%esp)
 14f:	e8 0c 03 00 00       	call   460 <open>
 154:	89 44 24 18          	mov    %eax,0x18(%esp)
 158:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
 15d:	79 2f                	jns    18e <main+0x91>
      printf(1, "wc: cannot open %s\n", argv[i]);
 15f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 163:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 16a:	8b 45 0c             	mov    0xc(%ebp),%eax
 16d:	01 d0                	add    %edx,%eax
 16f:	8b 00                	mov    (%eax),%eax
 171:	89 44 24 08          	mov    %eax,0x8(%esp)
 175:	c7 44 24 04 9b 09 00 	movl   $0x99b,0x4(%esp)
 17c:	00 
 17d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 184:	e8 27 04 00 00       	call   5b0 <printf>
      exit();
 189:	e8 92 02 00 00       	call   420 <exit>
    }
    wc(fd, argv[i]);
 18e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 192:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 199:	8b 45 0c             	mov    0xc(%ebp),%eax
 19c:	01 d0                	add    %edx,%eax
 19e:	8b 00                	mov    (%eax),%eax
 1a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 1a4:	8b 44 24 18          	mov    0x18(%esp),%eax
 1a8:	89 04 24             	mov    %eax,(%esp)
 1ab:	e8 50 fe ff ff       	call   0 <wc>
    close(fd);
 1b0:	8b 44 24 18          	mov    0x18(%esp),%eax
 1b4:	89 04 24             	mov    %eax,(%esp)
 1b7:	e8 8c 02 00 00       	call   448 <close>
  if(argc <= 1){
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
 1bc:	ff 44 24 1c          	incl   0x1c(%esp)
 1c0:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 1c4:	3b 45 08             	cmp    0x8(%ebp),%eax
 1c7:	0f 8c 65 ff ff ff    	jl     132 <main+0x35>
      exit();
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit();
 1cd:	e8 4e 02 00 00       	call   420 <exit>
 1d2:	66 90                	xchg   %ax,%ax

000001d4 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	57                   	push   %edi
 1d8:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1dc:	8b 55 10             	mov    0x10(%ebp),%edx
 1df:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e2:	89 cb                	mov    %ecx,%ebx
 1e4:	89 df                	mov    %ebx,%edi
 1e6:	89 d1                	mov    %edx,%ecx
 1e8:	fc                   	cld    
 1e9:	f3 aa                	rep stos %al,%es:(%edi)
 1eb:	89 ca                	mov    %ecx,%edx
 1ed:	89 fb                	mov    %edi,%ebx
 1ef:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1f2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1f5:	5b                   	pop    %ebx
 1f6:	5f                   	pop    %edi
 1f7:	5d                   	pop    %ebp
 1f8:	c3                   	ret    

000001f9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1ff:	8b 45 08             	mov    0x8(%ebp),%eax
 202:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 205:	90                   	nop
 206:	8b 45 0c             	mov    0xc(%ebp),%eax
 209:	8a 10                	mov    (%eax),%dl
 20b:	8b 45 08             	mov    0x8(%ebp),%eax
 20e:	88 10                	mov    %dl,(%eax)
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	8a 00                	mov    (%eax),%al
 215:	84 c0                	test   %al,%al
 217:	0f 95 c0             	setne  %al
 21a:	ff 45 08             	incl   0x8(%ebp)
 21d:	ff 45 0c             	incl   0xc(%ebp)
 220:	84 c0                	test   %al,%al
 222:	75 e2                	jne    206 <strcpy+0xd>
    ;
  return os;
 224:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 227:	c9                   	leave  
 228:	c3                   	ret    

00000229 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 229:	55                   	push   %ebp
 22a:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 22c:	eb 06                	jmp    234 <strcmp+0xb>
    p++, q++;
 22e:	ff 45 08             	incl   0x8(%ebp)
 231:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	8a 00                	mov    (%eax),%al
 239:	84 c0                	test   %al,%al
 23b:	74 0e                	je     24b <strcmp+0x22>
 23d:	8b 45 08             	mov    0x8(%ebp),%eax
 240:	8a 10                	mov    (%eax),%dl
 242:	8b 45 0c             	mov    0xc(%ebp),%eax
 245:	8a 00                	mov    (%eax),%al
 247:	38 c2                	cmp    %al,%dl
 249:	74 e3                	je     22e <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 24b:	8b 45 08             	mov    0x8(%ebp),%eax
 24e:	8a 00                	mov    (%eax),%al
 250:	0f b6 d0             	movzbl %al,%edx
 253:	8b 45 0c             	mov    0xc(%ebp),%eax
 256:	8a 00                	mov    (%eax),%al
 258:	0f b6 c0             	movzbl %al,%eax
 25b:	89 d1                	mov    %edx,%ecx
 25d:	29 c1                	sub    %eax,%ecx
 25f:	89 c8                	mov    %ecx,%eax
}
 261:	5d                   	pop    %ebp
 262:	c3                   	ret    

00000263 <strlen>:

uint
strlen(char *s)
{
 263:	55                   	push   %ebp
 264:	89 e5                	mov    %esp,%ebp
 266:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 269:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 270:	eb 03                	jmp    275 <strlen+0x12>
 272:	ff 45 fc             	incl   -0x4(%ebp)
 275:	8b 55 fc             	mov    -0x4(%ebp),%edx
 278:	8b 45 08             	mov    0x8(%ebp),%eax
 27b:	01 d0                	add    %edx,%eax
 27d:	8a 00                	mov    (%eax),%al
 27f:	84 c0                	test   %al,%al
 281:	75 ef                	jne    272 <strlen+0xf>
    ;
  return n;
 283:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 286:	c9                   	leave  
 287:	c3                   	ret    

00000288 <memset>:

void*
memset(void *dst, int c, uint n)
{
 288:	55                   	push   %ebp
 289:	89 e5                	mov    %esp,%ebp
 28b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 28e:	8b 45 10             	mov    0x10(%ebp),%eax
 291:	89 44 24 08          	mov    %eax,0x8(%esp)
 295:	8b 45 0c             	mov    0xc(%ebp),%eax
 298:	89 44 24 04          	mov    %eax,0x4(%esp)
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	89 04 24             	mov    %eax,(%esp)
 2a2:	e8 2d ff ff ff       	call   1d4 <stosb>
  return dst;
 2a7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2aa:	c9                   	leave  
 2ab:	c3                   	ret    

000002ac <strchr>:

char*
strchr(const char *s, char c)
{
 2ac:	55                   	push   %ebp
 2ad:	89 e5                	mov    %esp,%ebp
 2af:	83 ec 04             	sub    $0x4,%esp
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2b8:	eb 12                	jmp    2cc <strchr+0x20>
    if(*s == c)
 2ba:	8b 45 08             	mov    0x8(%ebp),%eax
 2bd:	8a 00                	mov    (%eax),%al
 2bf:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2c2:	75 05                	jne    2c9 <strchr+0x1d>
      return (char*)s;
 2c4:	8b 45 08             	mov    0x8(%ebp),%eax
 2c7:	eb 11                	jmp    2da <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2c9:	ff 45 08             	incl   0x8(%ebp)
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	8a 00                	mov    (%eax),%al
 2d1:	84 c0                	test   %al,%al
 2d3:	75 e5                	jne    2ba <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2da:	c9                   	leave  
 2db:	c3                   	ret    

000002dc <gets>:

char*
gets(char *buf, int max)
{
 2dc:	55                   	push   %ebp
 2dd:	89 e5                	mov    %esp,%ebp
 2df:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2e9:	eb 42                	jmp    32d <gets+0x51>
    cc = read(0, &c, 1);
 2eb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 2f2:	00 
 2f3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2f6:	89 44 24 04          	mov    %eax,0x4(%esp)
 2fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 301:	e8 32 01 00 00       	call   438 <read>
 306:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 309:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 30d:	7e 29                	jle    338 <gets+0x5c>
      break;
    buf[i++] = c;
 30f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 312:	8b 45 08             	mov    0x8(%ebp),%eax
 315:	01 c2                	add    %eax,%edx
 317:	8a 45 ef             	mov    -0x11(%ebp),%al
 31a:	88 02                	mov    %al,(%edx)
 31c:	ff 45 f4             	incl   -0xc(%ebp)
    if(c == '\n' || c == '\r')
 31f:	8a 45 ef             	mov    -0x11(%ebp),%al
 322:	3c 0a                	cmp    $0xa,%al
 324:	74 13                	je     339 <gets+0x5d>
 326:	8a 45 ef             	mov    -0x11(%ebp),%al
 329:	3c 0d                	cmp    $0xd,%al
 32b:	74 0c                	je     339 <gets+0x5d>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 330:	40                   	inc    %eax
 331:	3b 45 0c             	cmp    0xc(%ebp),%eax
 334:	7c b5                	jl     2eb <gets+0xf>
 336:	eb 01                	jmp    339 <gets+0x5d>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 338:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 339:	8b 55 f4             	mov    -0xc(%ebp),%edx
 33c:	8b 45 08             	mov    0x8(%ebp),%eax
 33f:	01 d0                	add    %edx,%eax
 341:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 344:	8b 45 08             	mov    0x8(%ebp),%eax
}
 347:	c9                   	leave  
 348:	c3                   	ret    

00000349 <stat>:

int
stat(char *n, struct stat *st)
{
 349:	55                   	push   %ebp
 34a:	89 e5                	mov    %esp,%ebp
 34c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 356:	00 
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	89 04 24             	mov    %eax,(%esp)
 35d:	e8 fe 00 00 00       	call   460 <open>
 362:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 365:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 369:	79 07                	jns    372 <stat+0x29>
    return -1;
 36b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 370:	eb 23                	jmp    395 <stat+0x4c>
  r = fstat(fd, st);
 372:	8b 45 0c             	mov    0xc(%ebp),%eax
 375:	89 44 24 04          	mov    %eax,0x4(%esp)
 379:	8b 45 f4             	mov    -0xc(%ebp),%eax
 37c:	89 04 24             	mov    %eax,(%esp)
 37f:	e8 f4 00 00 00       	call   478 <fstat>
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 387:	8b 45 f4             	mov    -0xc(%ebp),%eax
 38a:	89 04 24             	mov    %eax,(%esp)
 38d:	e8 b6 00 00 00       	call   448 <close>
  return r;
 392:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 395:	c9                   	leave  
 396:	c3                   	ret    

00000397 <atoi>:

int
atoi(const char *s)
{
 397:	55                   	push   %ebp
 398:	89 e5                	mov    %esp,%ebp
 39a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 39d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3a4:	eb 21                	jmp    3c7 <atoi+0x30>
    n = n*10 + *s++ - '0';
 3a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3a9:	89 d0                	mov    %edx,%eax
 3ab:	c1 e0 02             	shl    $0x2,%eax
 3ae:	01 d0                	add    %edx,%eax
 3b0:	d1 e0                	shl    %eax
 3b2:	89 c2                	mov    %eax,%edx
 3b4:	8b 45 08             	mov    0x8(%ebp),%eax
 3b7:	8a 00                	mov    (%eax),%al
 3b9:	0f be c0             	movsbl %al,%eax
 3bc:	01 d0                	add    %edx,%eax
 3be:	83 e8 30             	sub    $0x30,%eax
 3c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3c4:	ff 45 08             	incl   0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3c7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ca:	8a 00                	mov    (%eax),%al
 3cc:	3c 2f                	cmp    $0x2f,%al
 3ce:	7e 09                	jle    3d9 <atoi+0x42>
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	8a 00                	mov    (%eax),%al
 3d5:	3c 39                	cmp    $0x39,%al
 3d7:	7e cd                	jle    3a6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3dc:	c9                   	leave  
 3dd:	c3                   	ret    

000003de <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3de:	55                   	push   %ebp
 3df:	89 e5                	mov    %esp,%ebp
 3e1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3e4:	8b 45 08             	mov    0x8(%ebp),%eax
 3e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ed:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3f0:	eb 10                	jmp    402 <memmove+0x24>
    *dst++ = *src++;
 3f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 3f5:	8a 10                	mov    (%eax),%dl
 3f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3fa:	88 10                	mov    %dl,(%eax)
 3fc:	ff 45 fc             	incl   -0x4(%ebp)
 3ff:	ff 45 f8             	incl   -0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 402:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 406:	0f 9f c0             	setg   %al
 409:	ff 4d 10             	decl   0x10(%ebp)
 40c:	84 c0                	test   %al,%al
 40e:	75 e2                	jne    3f2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 410:	8b 45 08             	mov    0x8(%ebp),%eax
}
 413:	c9                   	leave  
 414:	c3                   	ret    
 415:	66 90                	xchg   %ax,%ax
 417:	90                   	nop

00000418 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 418:	b8 01 00 00 00       	mov    $0x1,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <exit>:
SYSCALL(exit)
 420:	b8 02 00 00 00       	mov    $0x2,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <wait>:
SYSCALL(wait)
 428:	b8 03 00 00 00       	mov    $0x3,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <pipe>:
SYSCALL(pipe)
 430:	b8 04 00 00 00       	mov    $0x4,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    

00000438 <read>:
SYSCALL(read)
 438:	b8 05 00 00 00       	mov    $0x5,%eax
 43d:	cd 40                	int    $0x40
 43f:	c3                   	ret    

00000440 <write>:
SYSCALL(write)
 440:	b8 10 00 00 00       	mov    $0x10,%eax
 445:	cd 40                	int    $0x40
 447:	c3                   	ret    

00000448 <close>:
SYSCALL(close)
 448:	b8 15 00 00 00       	mov    $0x15,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <kill>:
SYSCALL(kill)
 450:	b8 06 00 00 00       	mov    $0x6,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <exec>:
SYSCALL(exec)
 458:	b8 07 00 00 00       	mov    $0x7,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <open>:
SYSCALL(open)
 460:	b8 0f 00 00 00       	mov    $0xf,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <mknod>:
SYSCALL(mknod)
 468:	b8 11 00 00 00       	mov    $0x11,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <unlink>:
SYSCALL(unlink)
 470:	b8 12 00 00 00       	mov    $0x12,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <fstat>:
SYSCALL(fstat)
 478:	b8 08 00 00 00       	mov    $0x8,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <link>:
SYSCALL(link)
 480:	b8 13 00 00 00       	mov    $0x13,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <mkdir>:
SYSCALL(mkdir)
 488:	b8 14 00 00 00       	mov    $0x14,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <chdir>:
SYSCALL(chdir)
 490:	b8 09 00 00 00       	mov    $0x9,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <dup>:
SYSCALL(dup)
 498:	b8 0a 00 00 00       	mov    $0xa,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <getpid>:
SYSCALL(getpid)
 4a0:	b8 0b 00 00 00       	mov    $0xb,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <sbrk>:
SYSCALL(sbrk)
 4a8:	b8 0c 00 00 00       	mov    $0xc,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <sleep>:
SYSCALL(sleep)
 4b0:	b8 0d 00 00 00       	mov    $0xd,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <uptime>:
SYSCALL(uptime)
 4b8:	b8 0e 00 00 00       	mov    $0xe,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <getppid>:
SYSCALL(getppid)        // USER DEFINED SYS CALL
 4c0:	b8 16 00 00 00       	mov    $0x16,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <icount>:
SYSCALL(icount)         // USER DEFINED SYS CALL
 4c8:	b8 17 00 00 00       	mov    $0x17,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <signal>:
SYSCALL(signal)         // USER DEFINED SYS CALL
 4d0:	b8 18 00 00 00       	mov    $0x18,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4d8:	55                   	push   %ebp
 4d9:	89 e5                	mov    %esp,%ebp
 4db:	83 ec 28             	sub    $0x28,%esp
 4de:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4e4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 4eb:	00 
 4ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4ef:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f3:	8b 45 08             	mov    0x8(%ebp),%eax
 4f6:	89 04 24             	mov    %eax,(%esp)
 4f9:	e8 42 ff ff ff       	call   440 <write>
}
 4fe:	c9                   	leave  
 4ff:	c3                   	ret    

00000500 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 500:	55                   	push   %ebp
 501:	89 e5                	mov    %esp,%ebp
 503:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 506:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 50d:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 511:	74 17                	je     52a <printint+0x2a>
 513:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 517:	79 11                	jns    52a <printint+0x2a>
    neg = 1;
 519:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 520:	8b 45 0c             	mov    0xc(%ebp),%eax
 523:	f7 d8                	neg    %eax
 525:	89 45 ec             	mov    %eax,-0x14(%ebp)
 528:	eb 06                	jmp    530 <printint+0x30>
  } else {
    x = xx;
 52a:	8b 45 0c             	mov    0xc(%ebp),%eax
 52d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 530:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 537:	8b 4d 10             	mov    0x10(%ebp),%ecx
 53a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 53d:	ba 00 00 00 00       	mov    $0x0,%edx
 542:	f7 f1                	div    %ecx
 544:	89 d0                	mov    %edx,%eax
 546:	8a 80 14 0c 00 00    	mov    0xc14(%eax),%al
 54c:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 54f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 552:	01 ca                	add    %ecx,%edx
 554:	88 02                	mov    %al,(%edx)
 556:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
 559:	8b 55 10             	mov    0x10(%ebp),%edx
 55c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 55f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 562:	ba 00 00 00 00       	mov    $0x0,%edx
 567:	f7 75 d4             	divl   -0x2c(%ebp)
 56a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 56d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 571:	75 c4                	jne    537 <printint+0x37>
  if(neg)
 573:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 577:	74 2c                	je     5a5 <printint+0xa5>
    buf[i++] = '-';
 579:	8d 55 dc             	lea    -0x24(%ebp),%edx
 57c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 57f:	01 d0                	add    %edx,%eax
 581:	c6 00 2d             	movb   $0x2d,(%eax)
 584:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
 587:	eb 1c                	jmp    5a5 <printint+0xa5>
    putc(fd, buf[i]);
 589:	8d 55 dc             	lea    -0x24(%ebp),%edx
 58c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58f:	01 d0                	add    %edx,%eax
 591:	8a 00                	mov    (%eax),%al
 593:	0f be c0             	movsbl %al,%eax
 596:	89 44 24 04          	mov    %eax,0x4(%esp)
 59a:	8b 45 08             	mov    0x8(%ebp),%eax
 59d:	89 04 24             	mov    %eax,(%esp)
 5a0:	e8 33 ff ff ff       	call   4d8 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5a5:	ff 4d f4             	decl   -0xc(%ebp)
 5a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5ac:	79 db                	jns    589 <printint+0x89>
    putc(fd, buf[i]);
}
 5ae:	c9                   	leave  
 5af:	c3                   	ret    

000005b0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5b0:	55                   	push   %ebp
 5b1:	89 e5                	mov    %esp,%ebp
 5b3:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5bd:	8d 45 0c             	lea    0xc(%ebp),%eax
 5c0:	83 c0 04             	add    $0x4,%eax
 5c3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5c6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5cd:	e9 78 01 00 00       	jmp    74a <printf+0x19a>
    c = fmt[i] & 0xff;
 5d2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5d8:	01 d0                	add    %edx,%eax
 5da:	8a 00                	mov    (%eax),%al
 5dc:	0f be c0             	movsbl %al,%eax
 5df:	25 ff 00 00 00       	and    $0xff,%eax
 5e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5eb:	75 2c                	jne    619 <printf+0x69>
      if(c == '%'){
 5ed:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5f1:	75 0c                	jne    5ff <printf+0x4f>
        state = '%';
 5f3:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5fa:	e9 48 01 00 00       	jmp    747 <printf+0x197>
      } else {
        putc(fd, c);
 5ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 602:	0f be c0             	movsbl %al,%eax
 605:	89 44 24 04          	mov    %eax,0x4(%esp)
 609:	8b 45 08             	mov    0x8(%ebp),%eax
 60c:	89 04 24             	mov    %eax,(%esp)
 60f:	e8 c4 fe ff ff       	call   4d8 <putc>
 614:	e9 2e 01 00 00       	jmp    747 <printf+0x197>
      }
    } else if(state == '%'){
 619:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 61d:	0f 85 24 01 00 00    	jne    747 <printf+0x197>
      if(c == 'd'){
 623:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 627:	75 2d                	jne    656 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 629:	8b 45 e8             	mov    -0x18(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 635:	00 
 636:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 63d:	00 
 63e:	89 44 24 04          	mov    %eax,0x4(%esp)
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	89 04 24             	mov    %eax,(%esp)
 648:	e8 b3 fe ff ff       	call   500 <printint>
        ap++;
 64d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 651:	e9 ea 00 00 00       	jmp    740 <printf+0x190>
      } else if(c == 'x' || c == 'p'){
 656:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 65a:	74 06                	je     662 <printf+0xb2>
 65c:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 660:	75 2d                	jne    68f <printf+0xdf>
        printint(fd, *ap, 16, 0);
 662:	8b 45 e8             	mov    -0x18(%ebp),%eax
 665:	8b 00                	mov    (%eax),%eax
 667:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 66e:	00 
 66f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 676:	00 
 677:	89 44 24 04          	mov    %eax,0x4(%esp)
 67b:	8b 45 08             	mov    0x8(%ebp),%eax
 67e:	89 04 24             	mov    %eax,(%esp)
 681:	e8 7a fe ff ff       	call   500 <printint>
        ap++;
 686:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 68a:	e9 b1 00 00 00       	jmp    740 <printf+0x190>
      } else if(c == 's'){
 68f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 693:	75 43                	jne    6d8 <printf+0x128>
        s = (char*)*ap;
 695:	8b 45 e8             	mov    -0x18(%ebp),%eax
 698:	8b 00                	mov    (%eax),%eax
 69a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 69d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6a5:	75 25                	jne    6cc <printf+0x11c>
          s = "(null)";
 6a7:	c7 45 f4 af 09 00 00 	movl   $0x9af,-0xc(%ebp)
        while(*s != 0){
 6ae:	eb 1c                	jmp    6cc <printf+0x11c>
          putc(fd, *s);
 6b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b3:	8a 00                	mov    (%eax),%al
 6b5:	0f be c0             	movsbl %al,%eax
 6b8:	89 44 24 04          	mov    %eax,0x4(%esp)
 6bc:	8b 45 08             	mov    0x8(%ebp),%eax
 6bf:	89 04 24             	mov    %eax,(%esp)
 6c2:	e8 11 fe ff ff       	call   4d8 <putc>
          s++;
 6c7:	ff 45 f4             	incl   -0xc(%ebp)
 6ca:	eb 01                	jmp    6cd <printf+0x11d>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6cc:	90                   	nop
 6cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d0:	8a 00                	mov    (%eax),%al
 6d2:	84 c0                	test   %al,%al
 6d4:	75 da                	jne    6b0 <printf+0x100>
 6d6:	eb 68                	jmp    740 <printf+0x190>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d8:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6dc:	75 1d                	jne    6fb <printf+0x14b>
        putc(fd, *ap);
 6de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6e1:	8b 00                	mov    (%eax),%eax
 6e3:	0f be c0             	movsbl %al,%eax
 6e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ea:	8b 45 08             	mov    0x8(%ebp),%eax
 6ed:	89 04 24             	mov    %eax,(%esp)
 6f0:	e8 e3 fd ff ff       	call   4d8 <putc>
        ap++;
 6f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f9:	eb 45                	jmp    740 <printf+0x190>
      } else if(c == '%'){
 6fb:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ff:	75 17                	jne    718 <printf+0x168>
        putc(fd, c);
 701:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 704:	0f be c0             	movsbl %al,%eax
 707:	89 44 24 04          	mov    %eax,0x4(%esp)
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	89 04 24             	mov    %eax,(%esp)
 711:	e8 c2 fd ff ff       	call   4d8 <putc>
 716:	eb 28                	jmp    740 <printf+0x190>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 718:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 71f:	00 
 720:	8b 45 08             	mov    0x8(%ebp),%eax
 723:	89 04 24             	mov    %eax,(%esp)
 726:	e8 ad fd ff ff       	call   4d8 <putc>
        putc(fd, c);
 72b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 72e:	0f be c0             	movsbl %al,%eax
 731:	89 44 24 04          	mov    %eax,0x4(%esp)
 735:	8b 45 08             	mov    0x8(%ebp),%eax
 738:	89 04 24             	mov    %eax,(%esp)
 73b:	e8 98 fd ff ff       	call   4d8 <putc>
      }
      state = 0;
 740:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 747:	ff 45 f0             	incl   -0x10(%ebp)
 74a:	8b 55 0c             	mov    0xc(%ebp),%edx
 74d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 750:	01 d0                	add    %edx,%eax
 752:	8a 00                	mov    (%eax),%al
 754:	84 c0                	test   %al,%al
 756:	0f 85 76 fe ff ff    	jne    5d2 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 75c:	c9                   	leave  
 75d:	c3                   	ret    
 75e:	66 90                	xchg   %ax,%ax

00000760 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 760:	55                   	push   %ebp
 761:	89 e5                	mov    %esp,%ebp
 763:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 766:	8b 45 08             	mov    0x8(%ebp),%eax
 769:	83 e8 08             	sub    $0x8,%eax
 76c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76f:	a1 48 0c 00 00       	mov    0xc48,%eax
 774:	89 45 fc             	mov    %eax,-0x4(%ebp)
 777:	eb 24                	jmp    79d <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 779:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77c:	8b 00                	mov    (%eax),%eax
 77e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 781:	77 12                	ja     795 <free+0x35>
 783:	8b 45 f8             	mov    -0x8(%ebp),%eax
 786:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 789:	77 24                	ja     7af <free+0x4f>
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 793:	77 1a                	ja     7af <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 795:	8b 45 fc             	mov    -0x4(%ebp),%eax
 798:	8b 00                	mov    (%eax),%eax
 79a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a3:	76 d4                	jbe    779 <free+0x19>
 7a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a8:	8b 00                	mov    (%eax),%eax
 7aa:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7ad:	76 ca                	jbe    779 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7af:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b2:	8b 40 04             	mov    0x4(%eax),%eax
 7b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7bf:	01 c2                	add    %eax,%edx
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	8b 00                	mov    (%eax),%eax
 7c6:	39 c2                	cmp    %eax,%edx
 7c8:	75 24                	jne    7ee <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7ca:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7cd:	8b 50 04             	mov    0x4(%eax),%edx
 7d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d3:	8b 00                	mov    (%eax),%eax
 7d5:	8b 40 04             	mov    0x4(%eax),%eax
 7d8:	01 c2                	add    %eax,%edx
 7da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7dd:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e3:	8b 00                	mov    (%eax),%eax
 7e5:	8b 10                	mov    (%eax),%edx
 7e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ea:	89 10                	mov    %edx,(%eax)
 7ec:	eb 0a                	jmp    7f8 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f1:	8b 10                	mov    (%eax),%edx
 7f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f6:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7fb:	8b 40 04             	mov    0x4(%eax),%eax
 7fe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 805:	8b 45 fc             	mov    -0x4(%ebp),%eax
 808:	01 d0                	add    %edx,%eax
 80a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 80d:	75 20                	jne    82f <free+0xcf>
    p->s.size += bp->s.size;
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	8b 50 04             	mov    0x4(%eax),%edx
 815:	8b 45 f8             	mov    -0x8(%ebp),%eax
 818:	8b 40 04             	mov    0x4(%eax),%eax
 81b:	01 c2                	add    %eax,%edx
 81d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 820:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 823:	8b 45 f8             	mov    -0x8(%ebp),%eax
 826:	8b 10                	mov    (%eax),%edx
 828:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82b:	89 10                	mov    %edx,(%eax)
 82d:	eb 08                	jmp    837 <free+0xd7>
  } else
    p->s.ptr = bp;
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	8b 55 f8             	mov    -0x8(%ebp),%edx
 835:	89 10                	mov    %edx,(%eax)
  freep = p;
 837:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83a:	a3 48 0c 00 00       	mov    %eax,0xc48
}
 83f:	c9                   	leave  
 840:	c3                   	ret    

00000841 <morecore>:

static Header*
morecore(uint nu)
{
 841:	55                   	push   %ebp
 842:	89 e5                	mov    %esp,%ebp
 844:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 847:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 84e:	77 07                	ja     857 <morecore+0x16>
    nu = 4096;
 850:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 857:	8b 45 08             	mov    0x8(%ebp),%eax
 85a:	c1 e0 03             	shl    $0x3,%eax
 85d:	89 04 24             	mov    %eax,(%esp)
 860:	e8 43 fc ff ff       	call   4a8 <sbrk>
 865:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 868:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 86c:	75 07                	jne    875 <morecore+0x34>
    return 0;
 86e:	b8 00 00 00 00       	mov    $0x0,%eax
 873:	eb 22                	jmp    897 <morecore+0x56>
  hp = (Header*)p;
 875:	8b 45 f4             	mov    -0xc(%ebp),%eax
 878:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 87b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87e:	8b 55 08             	mov    0x8(%ebp),%edx
 881:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 884:	8b 45 f0             	mov    -0x10(%ebp),%eax
 887:	83 c0 08             	add    $0x8,%eax
 88a:	89 04 24             	mov    %eax,(%esp)
 88d:	e8 ce fe ff ff       	call   760 <free>
  return freep;
 892:	a1 48 0c 00 00       	mov    0xc48,%eax
}
 897:	c9                   	leave  
 898:	c3                   	ret    

00000899 <malloc>:

void*
malloc(uint nbytes)
{
 899:	55                   	push   %ebp
 89a:	89 e5                	mov    %esp,%ebp
 89c:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 89f:	8b 45 08             	mov    0x8(%ebp),%eax
 8a2:	83 c0 07             	add    $0x7,%eax
 8a5:	c1 e8 03             	shr    $0x3,%eax
 8a8:	40                   	inc    %eax
 8a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8ac:	a1 48 0c 00 00       	mov    0xc48,%eax
 8b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8b8:	75 23                	jne    8dd <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 8ba:	c7 45 f0 40 0c 00 00 	movl   $0xc40,-0x10(%ebp)
 8c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c4:	a3 48 0c 00 00       	mov    %eax,0xc48
 8c9:	a1 48 0c 00 00       	mov    0xc48,%eax
 8ce:	a3 40 0c 00 00       	mov    %eax,0xc40
    base.s.size = 0;
 8d3:	c7 05 44 0c 00 00 00 	movl   $0x0,0xc44
 8da:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e0:	8b 00                	mov    (%eax),%eax
 8e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e8:	8b 40 04             	mov    0x4(%eax),%eax
 8eb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8ee:	72 4d                	jb     93d <malloc+0xa4>
      if(p->s.size == nunits)
 8f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f3:	8b 40 04             	mov    0x4(%eax),%eax
 8f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f9:	75 0c                	jne    907 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	8b 10                	mov    (%eax),%edx
 900:	8b 45 f0             	mov    -0x10(%ebp),%eax
 903:	89 10                	mov    %edx,(%eax)
 905:	eb 26                	jmp    92d <malloc+0x94>
      else {
        p->s.size -= nunits;
 907:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90a:	8b 40 04             	mov    0x4(%eax),%eax
 90d:	89 c2                	mov    %eax,%edx
 90f:	2b 55 ec             	sub    -0x14(%ebp),%edx
 912:	8b 45 f4             	mov    -0xc(%ebp),%eax
 915:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 918:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91b:	8b 40 04             	mov    0x4(%eax),%eax
 91e:	c1 e0 03             	shl    $0x3,%eax
 921:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 924:	8b 45 f4             	mov    -0xc(%ebp),%eax
 927:	8b 55 ec             	mov    -0x14(%ebp),%edx
 92a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 92d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 930:	a3 48 0c 00 00       	mov    %eax,0xc48
      return (void*)(p + 1);
 935:	8b 45 f4             	mov    -0xc(%ebp),%eax
 938:	83 c0 08             	add    $0x8,%eax
 93b:	eb 38                	jmp    975 <malloc+0xdc>
    }
    if(p == freep)
 93d:	a1 48 0c 00 00       	mov    0xc48,%eax
 942:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 945:	75 1b                	jne    962 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 947:	8b 45 ec             	mov    -0x14(%ebp),%eax
 94a:	89 04 24             	mov    %eax,(%esp)
 94d:	e8 ef fe ff ff       	call   841 <morecore>
 952:	89 45 f4             	mov    %eax,-0xc(%ebp)
 955:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 959:	75 07                	jne    962 <malloc+0xc9>
        return 0;
 95b:	b8 00 00 00 00       	mov    $0x0,%eax
 960:	eb 13                	jmp    975 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 962:	8b 45 f4             	mov    -0xc(%ebp),%eax
 965:	89 45 f0             	mov    %eax,-0x10(%ebp)
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	8b 00                	mov    (%eax),%eax
 96d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 970:	e9 70 ff ff ff       	jmp    8e5 <malloc+0x4c>
}
 975:	c9                   	leave  
 976:	c3                   	ret    
