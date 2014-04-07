
_bigtest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main()
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	81 ec 30 02 00 00    	sub    $0x230,%esp
  char buf[512];
  int fd, i, sectors;

  fd = open("big.file", O_CREATE | O_WRONLY);
   c:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  13:	00 
  14:	c7 04 24 9c 09 00 00 	movl   $0x99c,(%esp)
  1b:	e8 64 04 00 00       	call   484 <open>
  20:	89 84 24 24 02 00 00 	mov    %eax,0x224(%esp)
  if(fd < 0){
  27:	83 bc 24 24 02 00 00 	cmpl   $0x0,0x224(%esp)
  2e:	00 
  2f:	79 19                	jns    4a <main+0x4a>
    printf(2, "big: cannot open big.file for writing\n");
  31:	c7 44 24 04 a8 09 00 	movl   $0x9a8,0x4(%esp)
  38:	00 
  39:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  40:	e8 8f 05 00 00       	call   5d4 <printf>
    exit();
  45:	e8 fa 03 00 00       	call   444 <exit>
  }

  sectors = 0;
  4a:	c7 84 24 28 02 00 00 	movl   $0x0,0x228(%esp)
  51:	00 00 00 00 
  55:	eb 01                	jmp    58 <main+0x58>
    if(cc <= 0)
      break;
    sectors++;
	if (sectors % 100 == 0)
		printf(2, ".");
  }
  57:	90                   	nop
    exit();
  }

  sectors = 0;
  while(1){
    *(int*)buf = sectors;
  58:	8d 44 24 1c          	lea    0x1c(%esp),%eax
  5c:	8b 94 24 28 02 00 00 	mov    0x228(%esp),%edx
  63:	89 10                	mov    %edx,(%eax)
    int cc = write(fd, buf, sizeof(buf));
  65:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  6c:	00 
  6d:	8d 44 24 1c          	lea    0x1c(%esp),%eax
  71:	89 44 24 04          	mov    %eax,0x4(%esp)
  75:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
  7c:	89 04 24             	mov    %eax,(%esp)
  7f:	e8 e0 03 00 00       	call   464 <write>
  84:	89 84 24 20 02 00 00 	mov    %eax,0x220(%esp)
    if(cc <= 0)
  8b:	83 bc 24 20 02 00 00 	cmpl   $0x0,0x220(%esp)
  92:	00 
  93:	7e 32                	jle    c7 <main+0xc7>
      break;
    sectors++;
  95:	ff 84 24 28 02 00 00 	incl   0x228(%esp)
	if (sectors % 100 == 0)
  9c:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
  a3:	b9 64 00 00 00       	mov    $0x64,%ecx
  a8:	99                   	cltd   
  a9:	f7 f9                	idiv   %ecx
  ab:	89 d0                	mov    %edx,%eax
  ad:	85 c0                	test   %eax,%eax
  af:	75 a6                	jne    57 <main+0x57>
		printf(2, ".");
  b1:	c7 44 24 04 cf 09 00 	movl   $0x9cf,0x4(%esp)
  b8:	00 
  b9:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  c0:	e8 0f 05 00 00       	call   5d4 <printf>
  }
  c5:	eb 90                	jmp    57 <main+0x57>
  sectors = 0;
  while(1){
    *(int*)buf = sectors;
    int cc = write(fd, buf, sizeof(buf));
    if(cc <= 0)
      break;
  c7:	90                   	nop
    sectors++;
	if (sectors % 100 == 0)
		printf(2, ".");
  }

  printf(1, "\nwrote %d sectors\n", sectors);
  c8:	8b 84 24 28 02 00 00 	mov    0x228(%esp),%eax
  cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  d3:	c7 44 24 04 d1 09 00 	movl   $0x9d1,0x4(%esp)
  da:	00 
  db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e2:	e8 ed 04 00 00       	call   5d4 <printf>

  close(fd);
  e7:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
  ee:	89 04 24             	mov    %eax,(%esp)
  f1:	e8 76 03 00 00       	call   46c <close>
  fd = open("big.file", O_RDONLY);
  f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  fd:	00 
  fe:	c7 04 24 9c 09 00 00 	movl   $0x99c,(%esp)
 105:	e8 7a 03 00 00       	call   484 <open>
 10a:	89 84 24 24 02 00 00 	mov    %eax,0x224(%esp)
  if(fd < 0){
 111:	83 bc 24 24 02 00 00 	cmpl   $0x0,0x224(%esp)
 118:	00 
 119:	79 19                	jns    134 <main+0x134>
    printf(2, "big: cannot re-open big.file for reading\n");
 11b:	c7 44 24 04 e4 09 00 	movl   $0x9e4,0x4(%esp)
 122:	00 
 123:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 12a:	e8 a5 04 00 00       	call   5d4 <printf>
    exit();
 12f:	e8 10 03 00 00       	call   444 <exit>
  }
  for(i = 0; i < sectors; i++){
 134:	c7 84 24 2c 02 00 00 	movl   $0x0,0x22c(%esp)
 13b:	00 00 00 00 
 13f:	e9 98 00 00 00       	jmp    1dc <main+0x1dc>
    int cc = read(fd, buf, sizeof(buf));
 144:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
 14b:	00 
 14c:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 150:	89 44 24 04          	mov    %eax,0x4(%esp)
 154:	8b 84 24 24 02 00 00 	mov    0x224(%esp),%eax
 15b:	89 04 24             	mov    %eax,(%esp)
 15e:	e8 f9 02 00 00       	call   45c <read>
 163:	89 84 24 1c 02 00 00 	mov    %eax,0x21c(%esp)
    if(cc <= 0){
 16a:	83 bc 24 1c 02 00 00 	cmpl   $0x0,0x21c(%esp)
 171:	00 
 172:	7f 24                	jg     198 <main+0x198>
      printf(2, "big: read error at sector %d\n", i);
 174:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
 17b:	89 44 24 08          	mov    %eax,0x8(%esp)
 17f:	c7 44 24 04 0e 0a 00 	movl   $0xa0e,0x4(%esp)
 186:	00 
 187:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 18e:	e8 41 04 00 00       	call   5d4 <printf>
      exit();
 193:	e8 ac 02 00 00       	call   444 <exit>
    }
    if(*(int*)buf != i){
 198:	8d 44 24 1c          	lea    0x1c(%esp),%eax
 19c:	8b 00                	mov    (%eax),%eax
 19e:	3b 84 24 2c 02 00 00 	cmp    0x22c(%esp),%eax
 1a5:	74 2e                	je     1d5 <main+0x1d5>
      printf(2, "big: read the wrong data (%d) for sector %d\n",
             *(int*)buf, i);
 1a7:	8d 44 24 1c          	lea    0x1c(%esp),%eax
    if(cc <= 0){
      printf(2, "big: read error at sector %d\n", i);
      exit();
    }
    if(*(int*)buf != i){
      printf(2, "big: read the wrong data (%d) for sector %d\n",
 1ab:	8b 00                	mov    (%eax),%eax
 1ad:	8b 94 24 2c 02 00 00 	mov    0x22c(%esp),%edx
 1b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
 1b8:	89 44 24 08          	mov    %eax,0x8(%esp)
 1bc:	c7 44 24 04 2c 0a 00 	movl   $0xa2c,0x4(%esp)
 1c3:	00 
 1c4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 1cb:	e8 04 04 00 00       	call   5d4 <printf>
             *(int*)buf, i);
      exit();
 1d0:	e8 6f 02 00 00       	call   444 <exit>
  fd = open("big.file", O_RDONLY);
  if(fd < 0){
    printf(2, "big: cannot re-open big.file for reading\n");
    exit();
  }
  for(i = 0; i < sectors; i++){
 1d5:	ff 84 24 2c 02 00 00 	incl   0x22c(%esp)
 1dc:	8b 84 24 2c 02 00 00 	mov    0x22c(%esp),%eax
 1e3:	3b 84 24 28 02 00 00 	cmp    0x228(%esp),%eax
 1ea:	0f 8c 54 ff ff ff    	jl     144 <main+0x144>
             *(int*)buf, i);
      exit();
    }
  }

  exit();
 1f0:	e8 4f 02 00 00       	call   444 <exit>
 1f5:	66 90                	xchg   %ax,%ax
 1f7:	90                   	nop

000001f8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1f8:	55                   	push   %ebp
 1f9:	89 e5                	mov    %esp,%ebp
 1fb:	57                   	push   %edi
 1fc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 200:	8b 55 10             	mov    0x10(%ebp),%edx
 203:	8b 45 0c             	mov    0xc(%ebp),%eax
 206:	89 cb                	mov    %ecx,%ebx
 208:	89 df                	mov    %ebx,%edi
 20a:	89 d1                	mov    %edx,%ecx
 20c:	fc                   	cld    
 20d:	f3 aa                	rep stos %al,%es:(%edi)
 20f:	89 ca                	mov    %ecx,%edx
 211:	89 fb                	mov    %edi,%ebx
 213:	89 5d 08             	mov    %ebx,0x8(%ebp)
 216:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 219:	5b                   	pop    %ebx
 21a:	5f                   	pop    %edi
 21b:	5d                   	pop    %ebp
 21c:	c3                   	ret    

0000021d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 21d:	55                   	push   %ebp
 21e:	89 e5                	mov    %esp,%ebp
 220:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 229:	90                   	nop
 22a:	8b 45 0c             	mov    0xc(%ebp),%eax
 22d:	8a 10                	mov    (%eax),%dl
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
 232:	88 10                	mov    %dl,(%eax)
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	8a 00                	mov    (%eax),%al
 239:	84 c0                	test   %al,%al
 23b:	0f 95 c0             	setne  %al
 23e:	ff 45 08             	incl   0x8(%ebp)
 241:	ff 45 0c             	incl   0xc(%ebp)
 244:	84 c0                	test   %al,%al
 246:	75 e2                	jne    22a <strcpy+0xd>
    ;
  return os;
 248:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 24b:	c9                   	leave  
 24c:	c3                   	ret    

0000024d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 24d:	55                   	push   %ebp
 24e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 250:	eb 06                	jmp    258 <strcmp+0xb>
    p++, q++;
 252:	ff 45 08             	incl   0x8(%ebp)
 255:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	8a 00                	mov    (%eax),%al
 25d:	84 c0                	test   %al,%al
 25f:	74 0e                	je     26f <strcmp+0x22>
 261:	8b 45 08             	mov    0x8(%ebp),%eax
 264:	8a 10                	mov    (%eax),%dl
 266:	8b 45 0c             	mov    0xc(%ebp),%eax
 269:	8a 00                	mov    (%eax),%al
 26b:	38 c2                	cmp    %al,%dl
 26d:	74 e3                	je     252 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 26f:	8b 45 08             	mov    0x8(%ebp),%eax
 272:	8a 00                	mov    (%eax),%al
 274:	0f b6 d0             	movzbl %al,%edx
 277:	8b 45 0c             	mov    0xc(%ebp),%eax
 27a:	8a 00                	mov    (%eax),%al
 27c:	0f b6 c0             	movzbl %al,%eax
 27f:	89 d1                	mov    %edx,%ecx
 281:	29 c1                	sub    %eax,%ecx
 283:	89 c8                	mov    %ecx,%eax
}
 285:	5d                   	pop    %ebp
 286:	c3                   	ret    

00000287 <strlen>:

uint
strlen(char *s)
{
 287:	55                   	push   %ebp
 288:	89 e5                	mov    %esp,%ebp
 28a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 28d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 294:	eb 03                	jmp    299 <strlen+0x12>
 296:	ff 45 fc             	incl   -0x4(%ebp)
 299:	8b 55 fc             	mov    -0x4(%ebp),%edx
 29c:	8b 45 08             	mov    0x8(%ebp),%eax
 29f:	01 d0                	add    %edx,%eax
 2a1:	8a 00                	mov    (%eax),%al
 2a3:	84 c0                	test   %al,%al
 2a5:	75 ef                	jne    296 <strlen+0xf>
    ;
  return n;
 2a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2aa:	c9                   	leave  
 2ab:	c3                   	ret    

000002ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ac:	55                   	push   %ebp
 2ad:	89 e5                	mov    %esp,%ebp
 2af:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 2b2:	8b 45 10             	mov    0x10(%ebp),%eax
 2b5:	89 44 24 08          	mov    %eax,0x8(%esp)
 2b9:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bc:	89 44 24 04          	mov    %eax,0x4(%esp)
 2c0:	8b 45 08             	mov    0x8(%ebp),%eax
 2c3:	89 04 24             	mov    %eax,(%esp)
 2c6:	e8 2d ff ff ff       	call   1f8 <stosb>
  return dst;
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ce:	c9                   	leave  
 2cf:	c3                   	ret    

000002d0 <strchr>:

char*
strchr(const char *s, char c)
{
 2d0:	55                   	push   %ebp
 2d1:	89 e5                	mov    %esp,%ebp
 2d3:	83 ec 04             	sub    $0x4,%esp
 2d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2dc:	eb 12                	jmp    2f0 <strchr+0x20>
    if(*s == c)
 2de:	8b 45 08             	mov    0x8(%ebp),%eax
 2e1:	8a 00                	mov    (%eax),%al
 2e3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2e6:	75 05                	jne    2ed <strchr+0x1d>
      return (char*)s;
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	eb 11                	jmp    2fe <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2ed:	ff 45 08             	incl   0x8(%ebp)
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	8a 00                	mov    (%eax),%al
 2f5:	84 c0                	test   %al,%al
 2f7:	75 e5                	jne    2de <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2fe:	c9                   	leave  
 2ff:	c3                   	ret    

00000300 <gets>:

char*
gets(char *buf, int max)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 306:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 30d:	eb 42                	jmp    351 <gets+0x51>
    cc = read(0, &c, 1);
 30f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 316:	00 
 317:	8d 45 ef             	lea    -0x11(%ebp),%eax
 31a:	89 44 24 04          	mov    %eax,0x4(%esp)
 31e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 325:	e8 32 01 00 00       	call   45c <read>
 32a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 32d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 331:	7e 29                	jle    35c <gets+0x5c>
      break;
    buf[i++] = c;
 333:	8b 55 f4             	mov    -0xc(%ebp),%edx
 336:	8b 45 08             	mov    0x8(%ebp),%eax
 339:	01 c2                	add    %eax,%edx
 33b:	8a 45 ef             	mov    -0x11(%ebp),%al
 33e:	88 02                	mov    %al,(%edx)
 340:	ff 45 f4             	incl   -0xc(%ebp)
    if(c == '\n' || c == '\r')
 343:	8a 45 ef             	mov    -0x11(%ebp),%al
 346:	3c 0a                	cmp    $0xa,%al
 348:	74 13                	je     35d <gets+0x5d>
 34a:	8a 45 ef             	mov    -0x11(%ebp),%al
 34d:	3c 0d                	cmp    $0xd,%al
 34f:	74 0c                	je     35d <gets+0x5d>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 351:	8b 45 f4             	mov    -0xc(%ebp),%eax
 354:	40                   	inc    %eax
 355:	3b 45 0c             	cmp    0xc(%ebp),%eax
 358:	7c b5                	jl     30f <gets+0xf>
 35a:	eb 01                	jmp    35d <gets+0x5d>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 35c:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 35d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 360:	8b 45 08             	mov    0x8(%ebp),%eax
 363:	01 d0                	add    %edx,%eax
 365:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 368:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36b:	c9                   	leave  
 36c:	c3                   	ret    

0000036d <stat>:

int
stat(char *n, struct stat *st)
{
 36d:	55                   	push   %ebp
 36e:	89 e5                	mov    %esp,%ebp
 370:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 373:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 37a:	00 
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	89 04 24             	mov    %eax,(%esp)
 381:	e8 fe 00 00 00       	call   484 <open>
 386:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 389:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 38d:	79 07                	jns    396 <stat+0x29>
    return -1;
 38f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 394:	eb 23                	jmp    3b9 <stat+0x4c>
  r = fstat(fd, st);
 396:	8b 45 0c             	mov    0xc(%ebp),%eax
 399:	89 44 24 04          	mov    %eax,0x4(%esp)
 39d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a0:	89 04 24             	mov    %eax,(%esp)
 3a3:	e8 f4 00 00 00       	call   49c <fstat>
 3a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ae:	89 04 24             	mov    %eax,(%esp)
 3b1:	e8 b6 00 00 00       	call   46c <close>
  return r;
 3b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3b9:	c9                   	leave  
 3ba:	c3                   	ret    

000003bb <atoi>:

int
atoi(const char *s)
{
 3bb:	55                   	push   %ebp
 3bc:	89 e5                	mov    %esp,%ebp
 3be:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3c1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3c8:	eb 21                	jmp    3eb <atoi+0x30>
    n = n*10 + *s++ - '0';
 3ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3cd:	89 d0                	mov    %edx,%eax
 3cf:	c1 e0 02             	shl    $0x2,%eax
 3d2:	01 d0                	add    %edx,%eax
 3d4:	d1 e0                	shl    %eax
 3d6:	89 c2                	mov    %eax,%edx
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
 3db:	8a 00                	mov    (%eax),%al
 3dd:	0f be c0             	movsbl %al,%eax
 3e0:	01 d0                	add    %edx,%eax
 3e2:	83 e8 30             	sub    $0x30,%eax
 3e5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 3e8:	ff 45 08             	incl   0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3eb:	8b 45 08             	mov    0x8(%ebp),%eax
 3ee:	8a 00                	mov    (%eax),%al
 3f0:	3c 2f                	cmp    $0x2f,%al
 3f2:	7e 09                	jle    3fd <atoi+0x42>
 3f4:	8b 45 08             	mov    0x8(%ebp),%eax
 3f7:	8a 00                	mov    (%eax),%al
 3f9:	3c 39                	cmp    $0x39,%al
 3fb:	7e cd                	jle    3ca <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 400:	c9                   	leave  
 401:	c3                   	ret    

00000402 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 402:	55                   	push   %ebp
 403:	89 e5                	mov    %esp,%ebp
 405:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 408:	8b 45 08             	mov    0x8(%ebp),%eax
 40b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 40e:	8b 45 0c             	mov    0xc(%ebp),%eax
 411:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 414:	eb 10                	jmp    426 <memmove+0x24>
    *dst++ = *src++;
 416:	8b 45 f8             	mov    -0x8(%ebp),%eax
 419:	8a 10                	mov    (%eax),%dl
 41b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 41e:	88 10                	mov    %dl,(%eax)
 420:	ff 45 fc             	incl   -0x4(%ebp)
 423:	ff 45 f8             	incl   -0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 426:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
 42a:	0f 9f c0             	setg   %al
 42d:	ff 4d 10             	decl   0x10(%ebp)
 430:	84 c0                	test   %al,%al
 432:	75 e2                	jne    416 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 434:	8b 45 08             	mov    0x8(%ebp),%eax
}
 437:	c9                   	leave  
 438:	c3                   	ret    
 439:	66 90                	xchg   %ax,%ax
 43b:	90                   	nop

0000043c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 43c:	b8 01 00 00 00       	mov    $0x1,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <exit>:
SYSCALL(exit)
 444:	b8 02 00 00 00       	mov    $0x2,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <wait>:
SYSCALL(wait)
 44c:	b8 03 00 00 00       	mov    $0x3,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <pipe>:
SYSCALL(pipe)
 454:	b8 04 00 00 00       	mov    $0x4,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <read>:
SYSCALL(read)
 45c:	b8 05 00 00 00       	mov    $0x5,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <write>:
SYSCALL(write)
 464:	b8 10 00 00 00       	mov    $0x10,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <close>:
SYSCALL(close)
 46c:	b8 15 00 00 00       	mov    $0x15,%eax
 471:	cd 40                	int    $0x40
 473:	c3                   	ret    

00000474 <kill>:
SYSCALL(kill)
 474:	b8 06 00 00 00       	mov    $0x6,%eax
 479:	cd 40                	int    $0x40
 47b:	c3                   	ret    

0000047c <exec>:
SYSCALL(exec)
 47c:	b8 07 00 00 00       	mov    $0x7,%eax
 481:	cd 40                	int    $0x40
 483:	c3                   	ret    

00000484 <open>:
SYSCALL(open)
 484:	b8 0f 00 00 00       	mov    $0xf,%eax
 489:	cd 40                	int    $0x40
 48b:	c3                   	ret    

0000048c <mknod>:
SYSCALL(mknod)
 48c:	b8 11 00 00 00       	mov    $0x11,%eax
 491:	cd 40                	int    $0x40
 493:	c3                   	ret    

00000494 <unlink>:
SYSCALL(unlink)
 494:	b8 12 00 00 00       	mov    $0x12,%eax
 499:	cd 40                	int    $0x40
 49b:	c3                   	ret    

0000049c <fstat>:
SYSCALL(fstat)
 49c:	b8 08 00 00 00       	mov    $0x8,%eax
 4a1:	cd 40                	int    $0x40
 4a3:	c3                   	ret    

000004a4 <link>:
SYSCALL(link)
 4a4:	b8 13 00 00 00       	mov    $0x13,%eax
 4a9:	cd 40                	int    $0x40
 4ab:	c3                   	ret    

000004ac <mkdir>:
SYSCALL(mkdir)
 4ac:	b8 14 00 00 00       	mov    $0x14,%eax
 4b1:	cd 40                	int    $0x40
 4b3:	c3                   	ret    

000004b4 <chdir>:
SYSCALL(chdir)
 4b4:	b8 09 00 00 00       	mov    $0x9,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret    

000004bc <dup>:
SYSCALL(dup)
 4bc:	b8 0a 00 00 00       	mov    $0xa,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret    

000004c4 <getpid>:
SYSCALL(getpid)
 4c4:	b8 0b 00 00 00       	mov    $0xb,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret    

000004cc <sbrk>:
SYSCALL(sbrk)
 4cc:	b8 0c 00 00 00       	mov    $0xc,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret    

000004d4 <sleep>:
SYSCALL(sleep)
 4d4:	b8 0d 00 00 00       	mov    $0xd,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret    

000004dc <uptime>:
SYSCALL(uptime)
 4dc:	b8 0e 00 00 00       	mov    $0xe,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret    

000004e4 <getppid>:
SYSCALL(getppid)        // USER DEFINED SYS CALL
 4e4:	b8 16 00 00 00       	mov    $0x16,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret    

000004ec <icount>:
SYSCALL(icount)         // USER DEFINED SYS CALL
 4ec:	b8 17 00 00 00       	mov    $0x17,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret    

000004f4 <signal>:
SYSCALL(signal)         // USER DEFINED SYS CALL
 4f4:	b8 18 00 00 00       	mov    $0x18,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret    

000004fc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4fc:	55                   	push   %ebp
 4fd:	89 e5                	mov    %esp,%ebp
 4ff:	83 ec 28             	sub    $0x28,%esp
 502:	8b 45 0c             	mov    0xc(%ebp),%eax
 505:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 508:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 50f:	00 
 510:	8d 45 f4             	lea    -0xc(%ebp),%eax
 513:	89 44 24 04          	mov    %eax,0x4(%esp)
 517:	8b 45 08             	mov    0x8(%ebp),%eax
 51a:	89 04 24             	mov    %eax,(%esp)
 51d:	e8 42 ff ff ff       	call   464 <write>
}
 522:	c9                   	leave  
 523:	c3                   	ret    

00000524 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 524:	55                   	push   %ebp
 525:	89 e5                	mov    %esp,%ebp
 527:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 52a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 531:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 535:	74 17                	je     54e <printint+0x2a>
 537:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 53b:	79 11                	jns    54e <printint+0x2a>
    neg = 1;
 53d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 544:	8b 45 0c             	mov    0xc(%ebp),%eax
 547:	f7 d8                	neg    %eax
 549:	89 45 ec             	mov    %eax,-0x14(%ebp)
 54c:	eb 06                	jmp    554 <printint+0x30>
  } else {
    x = xx;
 54e:	8b 45 0c             	mov    0xc(%ebp),%eax
 551:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 554:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 55b:	8b 4d 10             	mov    0x10(%ebp),%ecx
 55e:	8b 45 ec             	mov    -0x14(%ebp),%eax
 561:	ba 00 00 00 00       	mov    $0x0,%edx
 566:	f7 f1                	div    %ecx
 568:	89 d0                	mov    %edx,%eax
 56a:	8a 80 9c 0c 00 00    	mov    0xc9c(%eax),%al
 570:	8d 4d dc             	lea    -0x24(%ebp),%ecx
 573:	8b 55 f4             	mov    -0xc(%ebp),%edx
 576:	01 ca                	add    %ecx,%edx
 578:	88 02                	mov    %al,(%edx)
 57a:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
 57d:	8b 55 10             	mov    0x10(%ebp),%edx
 580:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 583:	8b 45 ec             	mov    -0x14(%ebp),%eax
 586:	ba 00 00 00 00       	mov    $0x0,%edx
 58b:	f7 75 d4             	divl   -0x2c(%ebp)
 58e:	89 45 ec             	mov    %eax,-0x14(%ebp)
 591:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 595:	75 c4                	jne    55b <printint+0x37>
  if(neg)
 597:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 59b:	74 2c                	je     5c9 <printint+0xa5>
    buf[i++] = '-';
 59d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a3:	01 d0                	add    %edx,%eax
 5a5:	c6 00 2d             	movb   $0x2d,(%eax)
 5a8:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
 5ab:	eb 1c                	jmp    5c9 <printint+0xa5>
    putc(fd, buf[i]);
 5ad:	8d 55 dc             	lea    -0x24(%ebp),%edx
 5b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b3:	01 d0                	add    %edx,%eax
 5b5:	8a 00                	mov    (%eax),%al
 5b7:	0f be c0             	movsbl %al,%eax
 5ba:	89 44 24 04          	mov    %eax,0x4(%esp)
 5be:	8b 45 08             	mov    0x8(%ebp),%eax
 5c1:	89 04 24             	mov    %eax,(%esp)
 5c4:	e8 33 ff ff ff       	call   4fc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5c9:	ff 4d f4             	decl   -0xc(%ebp)
 5cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d0:	79 db                	jns    5ad <printint+0x89>
    putc(fd, buf[i]);
}
 5d2:	c9                   	leave  
 5d3:	c3                   	ret    

000005d4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5d4:	55                   	push   %ebp
 5d5:	89 e5                	mov    %esp,%ebp
 5d7:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5da:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5e1:	8d 45 0c             	lea    0xc(%ebp),%eax
 5e4:	83 c0 04             	add    $0x4,%eax
 5e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5f1:	e9 78 01 00 00       	jmp    76e <printf+0x19a>
    c = fmt[i] & 0xff;
 5f6:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5fc:	01 d0                	add    %edx,%eax
 5fe:	8a 00                	mov    (%eax),%al
 600:	0f be c0             	movsbl %al,%eax
 603:	25 ff 00 00 00       	and    $0xff,%eax
 608:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 60b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 60f:	75 2c                	jne    63d <printf+0x69>
      if(c == '%'){
 611:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 615:	75 0c                	jne    623 <printf+0x4f>
        state = '%';
 617:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 61e:	e9 48 01 00 00       	jmp    76b <printf+0x197>
      } else {
        putc(fd, c);
 623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 626:	0f be c0             	movsbl %al,%eax
 629:	89 44 24 04          	mov    %eax,0x4(%esp)
 62d:	8b 45 08             	mov    0x8(%ebp),%eax
 630:	89 04 24             	mov    %eax,(%esp)
 633:	e8 c4 fe ff ff       	call   4fc <putc>
 638:	e9 2e 01 00 00       	jmp    76b <printf+0x197>
      }
    } else if(state == '%'){
 63d:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 641:	0f 85 24 01 00 00    	jne    76b <printf+0x197>
      if(c == 'd'){
 647:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 64b:	75 2d                	jne    67a <printf+0xa6>
        printint(fd, *ap, 10, 1);
 64d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 650:	8b 00                	mov    (%eax),%eax
 652:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 659:	00 
 65a:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 661:	00 
 662:	89 44 24 04          	mov    %eax,0x4(%esp)
 666:	8b 45 08             	mov    0x8(%ebp),%eax
 669:	89 04 24             	mov    %eax,(%esp)
 66c:	e8 b3 fe ff ff       	call   524 <printint>
        ap++;
 671:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 675:	e9 ea 00 00 00       	jmp    764 <printf+0x190>
      } else if(c == 'x' || c == 'p'){
 67a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 67e:	74 06                	je     686 <printf+0xb2>
 680:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 684:	75 2d                	jne    6b3 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 686:	8b 45 e8             	mov    -0x18(%ebp),%eax
 689:	8b 00                	mov    (%eax),%eax
 68b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 692:	00 
 693:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 69a:	00 
 69b:	89 44 24 04          	mov    %eax,0x4(%esp)
 69f:	8b 45 08             	mov    0x8(%ebp),%eax
 6a2:	89 04 24             	mov    %eax,(%esp)
 6a5:	e8 7a fe ff ff       	call   524 <printint>
        ap++;
 6aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ae:	e9 b1 00 00 00       	jmp    764 <printf+0x190>
      } else if(c == 's'){
 6b3:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6b7:	75 43                	jne    6fc <printf+0x128>
        s = (char*)*ap;
 6b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6bc:	8b 00                	mov    (%eax),%eax
 6be:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 6c1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 6c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 6c9:	75 25                	jne    6f0 <printf+0x11c>
          s = "(null)";
 6cb:	c7 45 f4 59 0a 00 00 	movl   $0xa59,-0xc(%ebp)
        while(*s != 0){
 6d2:	eb 1c                	jmp    6f0 <printf+0x11c>
          putc(fd, *s);
 6d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6d7:	8a 00                	mov    (%eax),%al
 6d9:	0f be c0             	movsbl %al,%eax
 6dc:	89 44 24 04          	mov    %eax,0x4(%esp)
 6e0:	8b 45 08             	mov    0x8(%ebp),%eax
 6e3:	89 04 24             	mov    %eax,(%esp)
 6e6:	e8 11 fe ff ff       	call   4fc <putc>
          s++;
 6eb:	ff 45 f4             	incl   -0xc(%ebp)
 6ee:	eb 01                	jmp    6f1 <printf+0x11d>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6f0:	90                   	nop
 6f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f4:	8a 00                	mov    (%eax),%al
 6f6:	84 c0                	test   %al,%al
 6f8:	75 da                	jne    6d4 <printf+0x100>
 6fa:	eb 68                	jmp    764 <printf+0x190>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6fc:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 700:	75 1d                	jne    71f <printf+0x14b>
        putc(fd, *ap);
 702:	8b 45 e8             	mov    -0x18(%ebp),%eax
 705:	8b 00                	mov    (%eax),%eax
 707:	0f be c0             	movsbl %al,%eax
 70a:	89 44 24 04          	mov    %eax,0x4(%esp)
 70e:	8b 45 08             	mov    0x8(%ebp),%eax
 711:	89 04 24             	mov    %eax,(%esp)
 714:	e8 e3 fd ff ff       	call   4fc <putc>
        ap++;
 719:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 71d:	eb 45                	jmp    764 <printf+0x190>
      } else if(c == '%'){
 71f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 723:	75 17                	jne    73c <printf+0x168>
        putc(fd, c);
 725:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 728:	0f be c0             	movsbl %al,%eax
 72b:	89 44 24 04          	mov    %eax,0x4(%esp)
 72f:	8b 45 08             	mov    0x8(%ebp),%eax
 732:	89 04 24             	mov    %eax,(%esp)
 735:	e8 c2 fd ff ff       	call   4fc <putc>
 73a:	eb 28                	jmp    764 <printf+0x190>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 73c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 743:	00 
 744:	8b 45 08             	mov    0x8(%ebp),%eax
 747:	89 04 24             	mov    %eax,(%esp)
 74a:	e8 ad fd ff ff       	call   4fc <putc>
        putc(fd, c);
 74f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 752:	0f be c0             	movsbl %al,%eax
 755:	89 44 24 04          	mov    %eax,0x4(%esp)
 759:	8b 45 08             	mov    0x8(%ebp),%eax
 75c:	89 04 24             	mov    %eax,(%esp)
 75f:	e8 98 fd ff ff       	call   4fc <putc>
      }
      state = 0;
 764:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 76b:	ff 45 f0             	incl   -0x10(%ebp)
 76e:	8b 55 0c             	mov    0xc(%ebp),%edx
 771:	8b 45 f0             	mov    -0x10(%ebp),%eax
 774:	01 d0                	add    %edx,%eax
 776:	8a 00                	mov    (%eax),%al
 778:	84 c0                	test   %al,%al
 77a:	0f 85 76 fe ff ff    	jne    5f6 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 780:	c9                   	leave  
 781:	c3                   	ret    
 782:	66 90                	xchg   %ax,%ax

00000784 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 784:	55                   	push   %ebp
 785:	89 e5                	mov    %esp,%ebp
 787:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78a:	8b 45 08             	mov    0x8(%ebp),%eax
 78d:	83 e8 08             	sub    $0x8,%eax
 790:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 793:	a1 b8 0c 00 00       	mov    0xcb8,%eax
 798:	89 45 fc             	mov    %eax,-0x4(%ebp)
 79b:	eb 24                	jmp    7c1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	8b 00                	mov    (%eax),%eax
 7a2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7a5:	77 12                	ja     7b9 <free+0x35>
 7a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7aa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7ad:	77 24                	ja     7d3 <free+0x4f>
 7af:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7b2:	8b 00                	mov    (%eax),%eax
 7b4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7b7:	77 1a                	ja     7d3 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 7c7:	76 d4                	jbe    79d <free+0x19>
 7c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cc:	8b 00                	mov    (%eax),%eax
 7ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7d1:	76 ca                	jbe    79d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7d3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d6:	8b 40 04             	mov    0x4(%eax),%eax
 7d9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e3:	01 c2                	add    %eax,%edx
 7e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e8:	8b 00                	mov    (%eax),%eax
 7ea:	39 c2                	cmp    %eax,%edx
 7ec:	75 24                	jne    812 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f1:	8b 50 04             	mov    0x4(%eax),%edx
 7f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f7:	8b 00                	mov    (%eax),%eax
 7f9:	8b 40 04             	mov    0x4(%eax),%eax
 7fc:	01 c2                	add    %eax,%edx
 7fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 801:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 804:	8b 45 fc             	mov    -0x4(%ebp),%eax
 807:	8b 00                	mov    (%eax),%eax
 809:	8b 10                	mov    (%eax),%edx
 80b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80e:	89 10                	mov    %edx,(%eax)
 810:	eb 0a                	jmp    81c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 812:	8b 45 fc             	mov    -0x4(%ebp),%eax
 815:	8b 10                	mov    (%eax),%edx
 817:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 81c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 81f:	8b 40 04             	mov    0x4(%eax),%eax
 822:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 829:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82c:	01 d0                	add    %edx,%eax
 82e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 831:	75 20                	jne    853 <free+0xcf>
    p->s.size += bp->s.size;
 833:	8b 45 fc             	mov    -0x4(%ebp),%eax
 836:	8b 50 04             	mov    0x4(%eax),%edx
 839:	8b 45 f8             	mov    -0x8(%ebp),%eax
 83c:	8b 40 04             	mov    0x4(%eax),%eax
 83f:	01 c2                	add    %eax,%edx
 841:	8b 45 fc             	mov    -0x4(%ebp),%eax
 844:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 847:	8b 45 f8             	mov    -0x8(%ebp),%eax
 84a:	8b 10                	mov    (%eax),%edx
 84c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84f:	89 10                	mov    %edx,(%eax)
 851:	eb 08                	jmp    85b <free+0xd7>
  } else
    p->s.ptr = bp;
 853:	8b 45 fc             	mov    -0x4(%ebp),%eax
 856:	8b 55 f8             	mov    -0x8(%ebp),%edx
 859:	89 10                	mov    %edx,(%eax)
  freep = p;
 85b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85e:	a3 b8 0c 00 00       	mov    %eax,0xcb8
}
 863:	c9                   	leave  
 864:	c3                   	ret    

00000865 <morecore>:

static Header*
morecore(uint nu)
{
 865:	55                   	push   %ebp
 866:	89 e5                	mov    %esp,%ebp
 868:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 86b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 872:	77 07                	ja     87b <morecore+0x16>
    nu = 4096;
 874:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 87b:	8b 45 08             	mov    0x8(%ebp),%eax
 87e:	c1 e0 03             	shl    $0x3,%eax
 881:	89 04 24             	mov    %eax,(%esp)
 884:	e8 43 fc ff ff       	call   4cc <sbrk>
 889:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 88c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 890:	75 07                	jne    899 <morecore+0x34>
    return 0;
 892:	b8 00 00 00 00       	mov    $0x0,%eax
 897:	eb 22                	jmp    8bb <morecore+0x56>
  hp = (Header*)p;
 899:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 89f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8a2:	8b 55 08             	mov    0x8(%ebp),%edx
 8a5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ab:	83 c0 08             	add    $0x8,%eax
 8ae:	89 04 24             	mov    %eax,(%esp)
 8b1:	e8 ce fe ff ff       	call   784 <free>
  return freep;
 8b6:	a1 b8 0c 00 00       	mov    0xcb8,%eax
}
 8bb:	c9                   	leave  
 8bc:	c3                   	ret    

000008bd <malloc>:

void*
malloc(uint nbytes)
{
 8bd:	55                   	push   %ebp
 8be:	89 e5                	mov    %esp,%ebp
 8c0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c3:	8b 45 08             	mov    0x8(%ebp),%eax
 8c6:	83 c0 07             	add    $0x7,%eax
 8c9:	c1 e8 03             	shr    $0x3,%eax
 8cc:	40                   	inc    %eax
 8cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8d0:	a1 b8 0c 00 00       	mov    0xcb8,%eax
 8d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8d8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8dc:	75 23                	jne    901 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 8de:	c7 45 f0 b0 0c 00 00 	movl   $0xcb0,-0x10(%ebp)
 8e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e8:	a3 b8 0c 00 00       	mov    %eax,0xcb8
 8ed:	a1 b8 0c 00 00       	mov    0xcb8,%eax
 8f2:	a3 b0 0c 00 00       	mov    %eax,0xcb0
    base.s.size = 0;
 8f7:	c7 05 b4 0c 00 00 00 	movl   $0x0,0xcb4
 8fe:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 901:	8b 45 f0             	mov    -0x10(%ebp),%eax
 904:	8b 00                	mov    (%eax),%eax
 906:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 909:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90c:	8b 40 04             	mov    0x4(%eax),%eax
 90f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 912:	72 4d                	jb     961 <malloc+0xa4>
      if(p->s.size == nunits)
 914:	8b 45 f4             	mov    -0xc(%ebp),%eax
 917:	8b 40 04             	mov    0x4(%eax),%eax
 91a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 91d:	75 0c                	jne    92b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 91f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 922:	8b 10                	mov    (%eax),%edx
 924:	8b 45 f0             	mov    -0x10(%ebp),%eax
 927:	89 10                	mov    %edx,(%eax)
 929:	eb 26                	jmp    951 <malloc+0x94>
      else {
        p->s.size -= nunits;
 92b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92e:	8b 40 04             	mov    0x4(%eax),%eax
 931:	89 c2                	mov    %eax,%edx
 933:	2b 55 ec             	sub    -0x14(%ebp),%edx
 936:	8b 45 f4             	mov    -0xc(%ebp),%eax
 939:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 93c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93f:	8b 40 04             	mov    0x4(%eax),%eax
 942:	c1 e0 03             	shl    $0x3,%eax
 945:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 948:	8b 45 f4             	mov    -0xc(%ebp),%eax
 94b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 94e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 951:	8b 45 f0             	mov    -0x10(%ebp),%eax
 954:	a3 b8 0c 00 00       	mov    %eax,0xcb8
      return (void*)(p + 1);
 959:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95c:	83 c0 08             	add    $0x8,%eax
 95f:	eb 38                	jmp    999 <malloc+0xdc>
    }
    if(p == freep)
 961:	a1 b8 0c 00 00       	mov    0xcb8,%eax
 966:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 969:	75 1b                	jne    986 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 96b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 96e:	89 04 24             	mov    %eax,(%esp)
 971:	e8 ef fe ff ff       	call   865 <morecore>
 976:	89 45 f4             	mov    %eax,-0xc(%ebp)
 979:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 97d:	75 07                	jne    986 <malloc+0xc9>
        return 0;
 97f:	b8 00 00 00 00       	mov    $0x0,%eax
 984:	eb 13                	jmp    999 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 986:	8b 45 f4             	mov    -0xc(%ebp),%eax
 989:	89 45 f0             	mov    %eax,-0x10(%ebp)
 98c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98f:	8b 00                	mov    (%eax),%eax
 991:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 994:	e9 70 ff ff ff       	jmp    909 <malloc+0x4c>
}
 999:	c9                   	leave  
 99a:	c3                   	ret    
