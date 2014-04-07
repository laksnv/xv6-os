
_sh:     file format elf32-i386


Disassembly of section .text:

00000000 <runcmd>:
struct cmd *parsecmd(char*);

// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
       6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
       a:	75 05                	jne    11 <runcmd+0x11>
    exit();
       c:	e8 17 0f 00 00       	call   f28 <exit>
  
  switch(cmd->type){
      11:	8b 45 08             	mov    0x8(%ebp),%eax
      14:	8b 00                	mov    (%eax),%eax
      16:	83 f8 05             	cmp    $0x5,%eax
      19:	77 09                	ja     24 <runcmd+0x24>
      1b:	8b 04 85 ac 14 00 00 	mov    0x14ac(,%eax,4),%eax
      22:	ff e0                	jmp    *%eax
  default:
    panic("runcmd");
      24:	c7 04 24 80 14 00 00 	movl   $0x1480,(%esp)
      2b:	e8 21 03 00 00       	call   351 <panic>

  case EXEC:
    ecmd = (struct execcmd*)cmd;
      30:	8b 45 08             	mov    0x8(%ebp),%eax
      33:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ecmd->argv[0] == 0)
      36:	8b 45 f4             	mov    -0xc(%ebp),%eax
      39:	8b 40 04             	mov    0x4(%eax),%eax
      3c:	85 c0                	test   %eax,%eax
      3e:	75 05                	jne    45 <runcmd+0x45>
      exit();
      40:	e8 e3 0e 00 00       	call   f28 <exit>
    exec(ecmd->argv[0], ecmd->argv);
      45:	8b 45 f4             	mov    -0xc(%ebp),%eax
      48:	8d 50 04             	lea    0x4(%eax),%edx
      4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
      4e:	8b 40 04             	mov    0x4(%eax),%eax
      51:	89 54 24 04          	mov    %edx,0x4(%esp)
      55:	89 04 24             	mov    %eax,(%esp)
      58:	e8 03 0f 00 00       	call   f60 <exec>
    printf(2, "exec %s failed\n", ecmd->argv[0]);
      5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
      60:	8b 40 04             	mov    0x4(%eax),%eax
      63:	89 44 24 08          	mov    %eax,0x8(%esp)
      67:	c7 44 24 04 87 14 00 	movl   $0x1487,0x4(%esp)
      6e:	00 
      6f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      76:	e8 3d 10 00 00       	call   10b8 <printf>
    break;
      7b:	e9 84 01 00 00       	jmp    204 <runcmd+0x204>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
      80:	8b 45 08             	mov    0x8(%ebp),%eax
      83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(rcmd->fd);
      86:	8b 45 f0             	mov    -0x10(%ebp),%eax
      89:	8b 40 14             	mov    0x14(%eax),%eax
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 bc 0e 00 00       	call   f50 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
      94:	8b 45 f0             	mov    -0x10(%ebp),%eax
      97:	8b 50 10             	mov    0x10(%eax),%edx
      9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
      9d:	8b 40 08             	mov    0x8(%eax),%eax
      a0:	89 54 24 04          	mov    %edx,0x4(%esp)
      a4:	89 04 24             	mov    %eax,(%esp)
      a7:	e8 bc 0e 00 00       	call   f68 <open>
      ac:	85 c0                	test   %eax,%eax
      ae:	79 23                	jns    d3 <runcmd+0xd3>
      printf(2, "open %s failed\n", rcmd->file);
      b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
      b3:	8b 40 08             	mov    0x8(%eax),%eax
      b6:	89 44 24 08          	mov    %eax,0x8(%esp)
      ba:	c7 44 24 04 97 14 00 	movl   $0x1497,0x4(%esp)
      c1:	00 
      c2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
      c9:	e8 ea 0f 00 00       	call   10b8 <printf>
      exit();
      ce:	e8 55 0e 00 00       	call   f28 <exit>
    }
    runcmd(rcmd->cmd);
      d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
      d6:	8b 40 04             	mov    0x4(%eax),%eax
      d9:	89 04 24             	mov    %eax,(%esp)
      dc:	e8 1f ff ff ff       	call   0 <runcmd>
    break;
      e1:	e9 1e 01 00 00       	jmp    204 <runcmd+0x204>

  case LIST:
    lcmd = (struct listcmd*)cmd;
      e6:	8b 45 08             	mov    0x8(%ebp),%eax
      e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fork1() == 0)
      ec:	e8 86 02 00 00       	call   377 <fork1>
      f1:	85 c0                	test   %eax,%eax
      f3:	75 0e                	jne    103 <runcmd+0x103>
      runcmd(lcmd->left);
      f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
      f8:	8b 40 04             	mov    0x4(%eax),%eax
      fb:	89 04 24             	mov    %eax,(%esp)
      fe:	e8 fd fe ff ff       	call   0 <runcmd>
    wait();
     103:	e8 28 0e 00 00       	call   f30 <wait>
    runcmd(lcmd->right);
     108:	8b 45 ec             	mov    -0x14(%ebp),%eax
     10b:	8b 40 08             	mov    0x8(%eax),%eax
     10e:	89 04 24             	mov    %eax,(%esp)
     111:	e8 ea fe ff ff       	call   0 <runcmd>
    break;
     116:	e9 e9 00 00 00       	jmp    204 <runcmd+0x204>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     11b:	8b 45 08             	mov    0x8(%ebp),%eax
     11e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pipe(p) < 0)
     121:	8d 45 dc             	lea    -0x24(%ebp),%eax
     124:	89 04 24             	mov    %eax,(%esp)
     127:	e8 0c 0e 00 00       	call   f38 <pipe>
     12c:	85 c0                	test   %eax,%eax
     12e:	79 0c                	jns    13c <runcmd+0x13c>
      panic("pipe");
     130:	c7 04 24 a7 14 00 00 	movl   $0x14a7,(%esp)
     137:	e8 15 02 00 00       	call   351 <panic>
    if(fork1() == 0){
     13c:	e8 36 02 00 00       	call   377 <fork1>
     141:	85 c0                	test   %eax,%eax
     143:	75 3b                	jne    180 <runcmd+0x180>
      close(1);
     145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     14c:	e8 ff 0d 00 00       	call   f50 <close>
      dup(p[1]);
     151:	8b 45 e0             	mov    -0x20(%ebp),%eax
     154:	89 04 24             	mov    %eax,(%esp)
     157:	e8 44 0e 00 00       	call   fa0 <dup>
      close(p[0]);
     15c:	8b 45 dc             	mov    -0x24(%ebp),%eax
     15f:	89 04 24             	mov    %eax,(%esp)
     162:	e8 e9 0d 00 00       	call   f50 <close>
      close(p[1]);
     167:	8b 45 e0             	mov    -0x20(%ebp),%eax
     16a:	89 04 24             	mov    %eax,(%esp)
     16d:	e8 de 0d 00 00       	call   f50 <close>
      runcmd(pcmd->left);
     172:	8b 45 e8             	mov    -0x18(%ebp),%eax
     175:	8b 40 04             	mov    0x4(%eax),%eax
     178:	89 04 24             	mov    %eax,(%esp)
     17b:	e8 80 fe ff ff       	call   0 <runcmd>
    }
    if(fork1() == 0){
     180:	e8 f2 01 00 00       	call   377 <fork1>
     185:	85 c0                	test   %eax,%eax
     187:	75 3b                	jne    1c4 <runcmd+0x1c4>
      close(0);
     189:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     190:	e8 bb 0d 00 00       	call   f50 <close>
      dup(p[0]);
     195:	8b 45 dc             	mov    -0x24(%ebp),%eax
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 00 0e 00 00       	call   fa0 <dup>
      close(p[0]);
     1a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1a3:	89 04 24             	mov    %eax,(%esp)
     1a6:	e8 a5 0d 00 00       	call   f50 <close>
      close(p[1]);
     1ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1ae:	89 04 24             	mov    %eax,(%esp)
     1b1:	e8 9a 0d 00 00       	call   f50 <close>
      runcmd(pcmd->right);
     1b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
     1b9:	8b 40 08             	mov    0x8(%eax),%eax
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 3c fe ff ff       	call   0 <runcmd>
    }
    close(p[0]);
     1c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
     1c7:	89 04 24             	mov    %eax,(%esp)
     1ca:	e8 81 0d 00 00       	call   f50 <close>
    close(p[1]);
     1cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
     1d2:	89 04 24             	mov    %eax,(%esp)
     1d5:	e8 76 0d 00 00       	call   f50 <close>
    wait();
     1da:	e8 51 0d 00 00       	call   f30 <wait>
    wait();
     1df:	e8 4c 0d 00 00       	call   f30 <wait>
    break;
     1e4:	eb 1e                	jmp    204 <runcmd+0x204>
    
  case BACK:
    bcmd = (struct backcmd*)cmd;
     1e6:	8b 45 08             	mov    0x8(%ebp),%eax
     1e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(fork1() == 0)
     1ec:	e8 86 01 00 00       	call   377 <fork1>
     1f1:	85 c0                	test   %eax,%eax
     1f3:	75 0e                	jne    203 <runcmd+0x203>
      runcmd(bcmd->cmd);
     1f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     1f8:	8b 40 04             	mov    0x4(%eax),%eax
     1fb:	89 04 24             	mov    %eax,(%esp)
     1fe:	e8 fd fd ff ff       	call   0 <runcmd>
    break;
     203:	90                   	nop
  }
  exit();
     204:	e8 1f 0d 00 00       	call   f28 <exit>

00000209 <getcmd>:
}

int
getcmd(char *buf, int nbuf)
{
     209:	55                   	push   %ebp
     20a:	89 e5                	mov    %esp,%ebp
     20c:	83 ec 18             	sub    $0x18,%esp
  printf(2, "$ ");
     20f:	c7 44 24 04 c4 14 00 	movl   $0x14c4,0x4(%esp)
     216:	00 
     217:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     21e:	e8 95 0e 00 00       	call   10b8 <printf>
  memset(buf, 0, nbuf);
     223:	8b 45 0c             	mov    0xc(%ebp),%eax
     226:	89 44 24 08          	mov    %eax,0x8(%esp)
     22a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     231:	00 
     232:	8b 45 08             	mov    0x8(%ebp),%eax
     235:	89 04 24             	mov    %eax,(%esp)
     238:	e8 53 0b 00 00       	call   d90 <memset>
  gets(buf, nbuf);
     23d:	8b 45 0c             	mov    0xc(%ebp),%eax
     240:	89 44 24 04          	mov    %eax,0x4(%esp)
     244:	8b 45 08             	mov    0x8(%ebp),%eax
     247:	89 04 24             	mov    %eax,(%esp)
     24a:	e8 95 0b 00 00       	call   de4 <gets>
  if(buf[0] == 0) // EOF
     24f:	8b 45 08             	mov    0x8(%ebp),%eax
     252:	8a 00                	mov    (%eax),%al
     254:	84 c0                	test   %al,%al
     256:	75 07                	jne    25f <getcmd+0x56>
    return -1;
     258:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     25d:	eb 05                	jmp    264 <getcmd+0x5b>
  return 0;
     25f:	b8 00 00 00 00       	mov    $0x0,%eax
}
     264:	c9                   	leave  
     265:	c3                   	ret    

00000266 <main>:

int
main(void)
{
     266:	55                   	push   %ebp
     267:	89 e5                	mov    %esp,%ebp
     269:	83 e4 f0             	and    $0xfffffff0,%esp
     26c:	83 ec 20             	sub    $0x20,%esp
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     26f:	eb 19                	jmp    28a <main+0x24>
    if(fd >= 3){
     271:	83 7c 24 1c 02       	cmpl   $0x2,0x1c(%esp)
     276:	7e 12                	jle    28a <main+0x24>
      close(fd);
     278:	8b 44 24 1c          	mov    0x1c(%esp),%eax
     27c:	89 04 24             	mov    %eax,(%esp)
     27f:	e8 cc 0c 00 00       	call   f50 <close>
      break;
     284:	90                   	nop
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     285:	e9 a6 00 00 00       	jmp    330 <main+0xca>
{
  static char buf[100];
  int fd;
  
  // Assumes three file descriptors open.
  while((fd = open("console", O_RDWR)) >= 0){
     28a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     291:	00 
     292:	c7 04 24 c7 14 00 00 	movl   $0x14c7,(%esp)
     299:	e8 ca 0c 00 00       	call   f68 <open>
     29e:	89 44 24 1c          	mov    %eax,0x1c(%esp)
     2a2:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
     2a7:	79 c8                	jns    271 <main+0xb>
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     2a9:	e9 82 00 00 00       	jmp    330 <main+0xca>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     2ae:	a0 20 1a 00 00       	mov    0x1a20,%al
     2b3:	3c 63                	cmp    $0x63,%al
     2b5:	75 54                	jne    30b <main+0xa5>
     2b7:	a0 21 1a 00 00       	mov    0x1a21,%al
     2bc:	3c 64                	cmp    $0x64,%al
     2be:	75 4b                	jne    30b <main+0xa5>
     2c0:	a0 22 1a 00 00       	mov    0x1a22,%al
     2c5:	3c 20                	cmp    $0x20,%al
     2c7:	75 42                	jne    30b <main+0xa5>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
     2c9:	c7 04 24 20 1a 00 00 	movl   $0x1a20,(%esp)
     2d0:	e8 96 0a 00 00       	call   d6b <strlen>
     2d5:	48                   	dec    %eax
     2d6:	c6 80 20 1a 00 00 00 	movb   $0x0,0x1a20(%eax)
      if(chdir(buf+3) < 0)
     2dd:	c7 04 24 23 1a 00 00 	movl   $0x1a23,(%esp)
     2e4:	e8 af 0c 00 00       	call   f98 <chdir>
     2e9:	85 c0                	test   %eax,%eax
     2eb:	79 42                	jns    32f <main+0xc9>
        printf(2, "cannot cd %s\n", buf+3);
     2ed:	c7 44 24 08 23 1a 00 	movl   $0x1a23,0x8(%esp)
     2f4:	00 
     2f5:	c7 44 24 04 cf 14 00 	movl   $0x14cf,0x4(%esp)
     2fc:	00 
     2fd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     304:	e8 af 0d 00 00       	call   10b8 <printf>
      continue;
     309:	eb 24                	jmp    32f <main+0xc9>
    }
    if(fork1() == 0)
     30b:	e8 67 00 00 00       	call   377 <fork1>
     310:	85 c0                	test   %eax,%eax
     312:	75 14                	jne    328 <main+0xc2>
      runcmd(parsecmd(buf));
     314:	c7 04 24 20 1a 00 00 	movl   $0x1a20,(%esp)
     31b:	e8 b4 03 00 00       	call   6d4 <parsecmd>
     320:	89 04 24             	mov    %eax,(%esp)
     323:	e8 d8 fc ff ff       	call   0 <runcmd>
    wait();
     328:	e8 03 0c 00 00       	call   f30 <wait>
     32d:	eb 01                	jmp    330 <main+0xca>
      // Clumsy but will have to do for now.
      // Chdir has no effect on the parent if run in the child.
      buf[strlen(buf)-1] = 0;  // chop \n
      if(chdir(buf+3) < 0)
        printf(2, "cannot cd %s\n", buf+3);
      continue;
     32f:	90                   	nop
      break;
    }
  }
  
  // Read and run input commands.
  while(getcmd(buf, sizeof(buf)) >= 0){
     330:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
     337:	00 
     338:	c7 04 24 20 1a 00 00 	movl   $0x1a20,(%esp)
     33f:	e8 c5 fe ff ff       	call   209 <getcmd>
     344:	85 c0                	test   %eax,%eax
     346:	0f 89 62 ff ff ff    	jns    2ae <main+0x48>
    }
    if(fork1() == 0)
      runcmd(parsecmd(buf));
    wait();
  }
  exit();
     34c:	e8 d7 0b 00 00       	call   f28 <exit>

00000351 <panic>:
}

void
panic(char *s)
{
     351:	55                   	push   %ebp
     352:	89 e5                	mov    %esp,%ebp
     354:	83 ec 18             	sub    $0x18,%esp
  printf(2, "%s\n", s);
     357:	8b 45 08             	mov    0x8(%ebp),%eax
     35a:	89 44 24 08          	mov    %eax,0x8(%esp)
     35e:	c7 44 24 04 dd 14 00 	movl   $0x14dd,0x4(%esp)
     365:	00 
     366:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     36d:	e8 46 0d 00 00       	call   10b8 <printf>
  exit();
     372:	e8 b1 0b 00 00       	call   f28 <exit>

00000377 <fork1>:
}

int
fork1(void)
{
     377:	55                   	push   %ebp
     378:	89 e5                	mov    %esp,%ebp
     37a:	83 ec 28             	sub    $0x28,%esp
  int pid;
  
  pid = fork();
     37d:	e8 9e 0b 00 00       	call   f20 <fork>
     382:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid == -1)
     385:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
     389:	75 0c                	jne    397 <fork1+0x20>
    panic("fork");
     38b:	c7 04 24 e1 14 00 00 	movl   $0x14e1,(%esp)
     392:	e8 ba ff ff ff       	call   351 <panic>
  return pid;
     397:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     39a:	c9                   	leave  
     39b:	c3                   	ret    

0000039c <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     39c:	55                   	push   %ebp
     39d:	89 e5                	mov    %esp,%ebp
     39f:	83 ec 28             	sub    $0x28,%esp
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3a2:	c7 04 24 54 00 00 00 	movl   $0x54,(%esp)
     3a9:	e8 f3 0f 00 00       	call   13a1 <malloc>
     3ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3b1:	c7 44 24 08 54 00 00 	movl   $0x54,0x8(%esp)
     3b8:	00 
     3b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3c0:	00 
     3c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3c4:	89 04 24             	mov    %eax,(%esp)
     3c7:	e8 c4 09 00 00       	call   d90 <memset>
  cmd->type = EXEC;
     3cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
     3cf:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  return (struct cmd*)cmd;
     3d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     3d8:	c9                   	leave  
     3d9:	c3                   	ret    

000003da <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     3da:	55                   	push   %ebp
     3db:	89 e5                	mov    %esp,%ebp
     3dd:	83 ec 28             	sub    $0x28,%esp
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3e0:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
     3e7:	e8 b5 0f 00 00       	call   13a1 <malloc>
     3ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     3ef:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
     3f6:	00 
     3f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     3fe:	00 
     3ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
     402:	89 04 24             	mov    %eax,(%esp)
     405:	e8 86 09 00 00       	call   d90 <memset>
  cmd->type = REDIR;
     40a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     40d:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  cmd->cmd = subcmd;
     413:	8b 45 f4             	mov    -0xc(%ebp),%eax
     416:	8b 55 08             	mov    0x8(%ebp),%edx
     419:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->file = file;
     41c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     41f:	8b 55 0c             	mov    0xc(%ebp),%edx
     422:	89 50 08             	mov    %edx,0x8(%eax)
  cmd->efile = efile;
     425:	8b 45 f4             	mov    -0xc(%ebp),%eax
     428:	8b 55 10             	mov    0x10(%ebp),%edx
     42b:	89 50 0c             	mov    %edx,0xc(%eax)
  cmd->mode = mode;
     42e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     431:	8b 55 14             	mov    0x14(%ebp),%edx
     434:	89 50 10             	mov    %edx,0x10(%eax)
  cmd->fd = fd;
     437:	8b 45 f4             	mov    -0xc(%ebp),%eax
     43a:	8b 55 18             	mov    0x18(%ebp),%edx
     43d:	89 50 14             	mov    %edx,0x14(%eax)
  return (struct cmd*)cmd;
     440:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     443:	c9                   	leave  
     444:	c3                   	ret    

00000445 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     445:	55                   	push   %ebp
     446:	89 e5                	mov    %esp,%ebp
     448:	83 ec 28             	sub    $0x28,%esp
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     44b:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     452:	e8 4a 0f 00 00       	call   13a1 <malloc>
     457:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     45a:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     461:	00 
     462:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     469:	00 
     46a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     46d:	89 04 24             	mov    %eax,(%esp)
     470:	e8 1b 09 00 00       	call   d90 <memset>
  cmd->type = PIPE;
     475:	8b 45 f4             	mov    -0xc(%ebp),%eax
     478:	c7 00 03 00 00 00    	movl   $0x3,(%eax)
  cmd->left = left;
     47e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     481:	8b 55 08             	mov    0x8(%ebp),%edx
     484:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     487:	8b 45 f4             	mov    -0xc(%ebp),%eax
     48a:	8b 55 0c             	mov    0xc(%ebp),%edx
     48d:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     490:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     493:	c9                   	leave  
     494:	c3                   	ret    

00000495 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     495:	55                   	push   %ebp
     496:	89 e5                	mov    %esp,%ebp
     498:	83 ec 28             	sub    $0x28,%esp
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     49b:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
     4a2:	e8 fa 0e 00 00       	call   13a1 <malloc>
     4a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4aa:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
     4b1:	00 
     4b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     4b9:	00 
     4ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4bd:	89 04 24             	mov    %eax,(%esp)
     4c0:	e8 cb 08 00 00       	call   d90 <memset>
  cmd->type = LIST;
     4c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4c8:	c7 00 04 00 00 00    	movl   $0x4,(%eax)
  cmd->left = left;
     4ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4d1:	8b 55 08             	mov    0x8(%ebp),%edx
     4d4:	89 50 04             	mov    %edx,0x4(%eax)
  cmd->right = right;
     4d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
     4da:	8b 55 0c             	mov    0xc(%ebp),%edx
     4dd:	89 50 08             	mov    %edx,0x8(%eax)
  return (struct cmd*)cmd;
     4e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     4e3:	c9                   	leave  
     4e4:	c3                   	ret    

000004e5 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     4e5:	55                   	push   %ebp
     4e6:	89 e5                	mov    %esp,%ebp
     4e8:	83 ec 28             	sub    $0x28,%esp
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4eb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
     4f2:	e8 aa 0e 00 00       	call   13a1 <malloc>
     4f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(cmd, 0, sizeof(*cmd));
     4fa:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
     501:	00 
     502:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     509:	00 
     50a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     50d:	89 04 24             	mov    %eax,(%esp)
     510:	e8 7b 08 00 00       	call   d90 <memset>
  cmd->type = BACK;
     515:	8b 45 f4             	mov    -0xc(%ebp),%eax
     518:	c7 00 05 00 00 00    	movl   $0x5,(%eax)
  cmd->cmd = subcmd;
     51e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     521:	8b 55 08             	mov    0x8(%ebp),%edx
     524:	89 50 04             	mov    %edx,0x4(%eax)
  return (struct cmd*)cmd;
     527:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     52a:	c9                   	leave  
     52b:	c3                   	ret    

0000052c <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     52c:	55                   	push   %ebp
     52d:	89 e5                	mov    %esp,%ebp
     52f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int ret;
  
  s = *ps;
     532:	8b 45 08             	mov    0x8(%ebp),%eax
     535:	8b 00                	mov    (%eax),%eax
     537:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     53a:	eb 03                	jmp    53f <gettoken+0x13>
    s++;
     53c:	ff 45 f4             	incl   -0xc(%ebp)
{
  char *s;
  int ret;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     53f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     542:	3b 45 0c             	cmp    0xc(%ebp),%eax
     545:	73 1c                	jae    563 <gettoken+0x37>
     547:	8b 45 f4             	mov    -0xc(%ebp),%eax
     54a:	8a 00                	mov    (%eax),%al
     54c:	0f be c0             	movsbl %al,%eax
     54f:	89 44 24 04          	mov    %eax,0x4(%esp)
     553:	c7 04 24 f0 19 00 00 	movl   $0x19f0,(%esp)
     55a:	e8 55 08 00 00       	call   db4 <strchr>
     55f:	85 c0                	test   %eax,%eax
     561:	75 d9                	jne    53c <gettoken+0x10>
    s++;
  if(q)
     563:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     567:	74 08                	je     571 <gettoken+0x45>
    *q = s;
     569:	8b 45 10             	mov    0x10(%ebp),%eax
     56c:	8b 55 f4             	mov    -0xc(%ebp),%edx
     56f:	89 10                	mov    %edx,(%eax)
  ret = *s;
     571:	8b 45 f4             	mov    -0xc(%ebp),%eax
     574:	8a 00                	mov    (%eax),%al
     576:	0f be c0             	movsbl %al,%eax
     579:	89 45 f0             	mov    %eax,-0x10(%ebp)
  switch(*s){
     57c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     57f:	8a 00                	mov    (%eax),%al
     581:	0f be c0             	movsbl %al,%eax
     584:	83 f8 3c             	cmp    $0x3c,%eax
     587:	7f 1a                	jg     5a3 <gettoken+0x77>
     589:	83 f8 3b             	cmp    $0x3b,%eax
     58c:	7d 1f                	jge    5ad <gettoken+0x81>
     58e:	83 f8 29             	cmp    $0x29,%eax
     591:	7f 37                	jg     5ca <gettoken+0x9e>
     593:	83 f8 28             	cmp    $0x28,%eax
     596:	7d 15                	jge    5ad <gettoken+0x81>
     598:	85 c0                	test   %eax,%eax
     59a:	74 7c                	je     618 <gettoken+0xec>
     59c:	83 f8 26             	cmp    $0x26,%eax
     59f:	74 0c                	je     5ad <gettoken+0x81>
     5a1:	eb 27                	jmp    5ca <gettoken+0x9e>
     5a3:	83 f8 3e             	cmp    $0x3e,%eax
     5a6:	74 0a                	je     5b2 <gettoken+0x86>
     5a8:	83 f8 7c             	cmp    $0x7c,%eax
     5ab:	75 1d                	jne    5ca <gettoken+0x9e>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5ad:	ff 45 f4             	incl   -0xc(%ebp)
    break;
     5b0:	eb 6d                	jmp    61f <gettoken+0xf3>
  case '>':
    s++;
     5b2:	ff 45 f4             	incl   -0xc(%ebp)
    if(*s == '>'){
     5b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5b8:	8a 00                	mov    (%eax),%al
     5ba:	3c 3e                	cmp    $0x3e,%al
     5bc:	75 5d                	jne    61b <gettoken+0xef>
      ret = '+';
     5be:	c7 45 f0 2b 00 00 00 	movl   $0x2b,-0x10(%ebp)
      s++;
     5c5:	ff 45 f4             	incl   -0xc(%ebp)
    }
    break;
     5c8:	eb 51                	jmp    61b <gettoken+0xef>
  default:
    ret = 'a';
     5ca:	c7 45 f0 61 00 00 00 	movl   $0x61,-0x10(%ebp)
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5d1:	eb 03                	jmp    5d6 <gettoken+0xaa>
      s++;
     5d3:	ff 45 f4             	incl   -0xc(%ebp)
      s++;
    }
    break;
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5d9:	3b 45 0c             	cmp    0xc(%ebp),%eax
     5dc:	73 40                	jae    61e <gettoken+0xf2>
     5de:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5e1:	8a 00                	mov    (%eax),%al
     5e3:	0f be c0             	movsbl %al,%eax
     5e6:	89 44 24 04          	mov    %eax,0x4(%esp)
     5ea:	c7 04 24 f0 19 00 00 	movl   $0x19f0,(%esp)
     5f1:	e8 be 07 00 00       	call   db4 <strchr>
     5f6:	85 c0                	test   %eax,%eax
     5f8:	75 24                	jne    61e <gettoken+0xf2>
     5fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
     5fd:	8a 00                	mov    (%eax),%al
     5ff:	0f be c0             	movsbl %al,%eax
     602:	89 44 24 04          	mov    %eax,0x4(%esp)
     606:	c7 04 24 f6 19 00 00 	movl   $0x19f6,(%esp)
     60d:	e8 a2 07 00 00       	call   db4 <strchr>
     612:	85 c0                	test   %eax,%eax
     614:	74 bd                	je     5d3 <gettoken+0xa7>
      s++;
    break;
     616:	eb 06                	jmp    61e <gettoken+0xf2>
  if(q)
    *q = s;
  ret = *s;
  switch(*s){
  case 0:
    break;
     618:	90                   	nop
     619:	eb 04                	jmp    61f <gettoken+0xf3>
    s++;
    if(*s == '>'){
      ret = '+';
      s++;
    }
    break;
     61b:	90                   	nop
     61c:	eb 01                	jmp    61f <gettoken+0xf3>
  default:
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
     61e:	90                   	nop
  }
  if(eq)
     61f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
     623:	74 0d                	je     632 <gettoken+0x106>
    *eq = s;
     625:	8b 45 14             	mov    0x14(%ebp),%eax
     628:	8b 55 f4             	mov    -0xc(%ebp),%edx
     62b:	89 10                	mov    %edx,(%eax)
  
  while(s < es && strchr(whitespace, *s))
     62d:	eb 03                	jmp    632 <gettoken+0x106>
    s++;
     62f:	ff 45 f4             	incl   -0xc(%ebp)
    break;
  }
  if(eq)
    *eq = s;
  
  while(s < es && strchr(whitespace, *s))
     632:	8b 45 f4             	mov    -0xc(%ebp),%eax
     635:	3b 45 0c             	cmp    0xc(%ebp),%eax
     638:	73 1c                	jae    656 <gettoken+0x12a>
     63a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     63d:	8a 00                	mov    (%eax),%al
     63f:	0f be c0             	movsbl %al,%eax
     642:	89 44 24 04          	mov    %eax,0x4(%esp)
     646:	c7 04 24 f0 19 00 00 	movl   $0x19f0,(%esp)
     64d:	e8 62 07 00 00       	call   db4 <strchr>
     652:	85 c0                	test   %eax,%eax
     654:	75 d9                	jne    62f <gettoken+0x103>
    s++;
  *ps = s;
     656:	8b 45 08             	mov    0x8(%ebp),%eax
     659:	8b 55 f4             	mov    -0xc(%ebp),%edx
     65c:	89 10                	mov    %edx,(%eax)
  return ret;
     65e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     661:	c9                   	leave  
     662:	c3                   	ret    

00000663 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     663:	55                   	push   %ebp
     664:	89 e5                	mov    %esp,%ebp
     666:	83 ec 28             	sub    $0x28,%esp
  char *s;
  
  s = *ps;
     669:	8b 45 08             	mov    0x8(%ebp),%eax
     66c:	8b 00                	mov    (%eax),%eax
     66e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(s < es && strchr(whitespace, *s))
     671:	eb 03                	jmp    676 <peek+0x13>
    s++;
     673:	ff 45 f4             	incl   -0xc(%ebp)
peek(char **ps, char *es, char *toks)
{
  char *s;
  
  s = *ps;
  while(s < es && strchr(whitespace, *s))
     676:	8b 45 f4             	mov    -0xc(%ebp),%eax
     679:	3b 45 0c             	cmp    0xc(%ebp),%eax
     67c:	73 1c                	jae    69a <peek+0x37>
     67e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     681:	8a 00                	mov    (%eax),%al
     683:	0f be c0             	movsbl %al,%eax
     686:	89 44 24 04          	mov    %eax,0x4(%esp)
     68a:	c7 04 24 f0 19 00 00 	movl   $0x19f0,(%esp)
     691:	e8 1e 07 00 00       	call   db4 <strchr>
     696:	85 c0                	test   %eax,%eax
     698:	75 d9                	jne    673 <peek+0x10>
    s++;
  *ps = s;
     69a:	8b 45 08             	mov    0x8(%ebp),%eax
     69d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     6a0:	89 10                	mov    %edx,(%eax)
  return *s && strchr(toks, *s);
     6a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6a5:	8a 00                	mov    (%eax),%al
     6a7:	84 c0                	test   %al,%al
     6a9:	74 22                	je     6cd <peek+0x6a>
     6ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6ae:	8a 00                	mov    (%eax),%al
     6b0:	0f be c0             	movsbl %al,%eax
     6b3:	89 44 24 04          	mov    %eax,0x4(%esp)
     6b7:	8b 45 10             	mov    0x10(%ebp),%eax
     6ba:	89 04 24             	mov    %eax,(%esp)
     6bd:	e8 f2 06 00 00       	call   db4 <strchr>
     6c2:	85 c0                	test   %eax,%eax
     6c4:	74 07                	je     6cd <peek+0x6a>
     6c6:	b8 01 00 00 00       	mov    $0x1,%eax
     6cb:	eb 05                	jmp    6d2 <peek+0x6f>
     6cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
     6d2:	c9                   	leave  
     6d3:	c3                   	ret    

000006d4 <parsecmd>:
struct cmd *parseexec(char**, char*);
struct cmd *nulterminate(struct cmd*);

struct cmd*
parsecmd(char *s)
{
     6d4:	55                   	push   %ebp
     6d5:	89 e5                	mov    %esp,%ebp
     6d7:	53                   	push   %ebx
     6d8:	83 ec 24             	sub    $0x24,%esp
  char *es;
  struct cmd *cmd;

  es = s + strlen(s);
     6db:	8b 5d 08             	mov    0x8(%ebp),%ebx
     6de:	8b 45 08             	mov    0x8(%ebp),%eax
     6e1:	89 04 24             	mov    %eax,(%esp)
     6e4:	e8 82 06 00 00       	call   d6b <strlen>
     6e9:	01 d8                	add    %ebx,%eax
     6eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cmd = parseline(&s, es);
     6ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
     6f1:	89 44 24 04          	mov    %eax,0x4(%esp)
     6f5:	8d 45 08             	lea    0x8(%ebp),%eax
     6f8:	89 04 24             	mov    %eax,(%esp)
     6fb:	e8 60 00 00 00       	call   760 <parseline>
     700:	89 45 f0             	mov    %eax,-0x10(%ebp)
  peek(&s, es, "");
     703:	c7 44 24 08 e6 14 00 	movl   $0x14e6,0x8(%esp)
     70a:	00 
     70b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     70e:	89 44 24 04          	mov    %eax,0x4(%esp)
     712:	8d 45 08             	lea    0x8(%ebp),%eax
     715:	89 04 24             	mov    %eax,(%esp)
     718:	e8 46 ff ff ff       	call   663 <peek>
  if(s != es){
     71d:	8b 45 08             	mov    0x8(%ebp),%eax
     720:	3b 45 f4             	cmp    -0xc(%ebp),%eax
     723:	74 27                	je     74c <parsecmd+0x78>
    printf(2, "leftovers: %s\n", s);
     725:	8b 45 08             	mov    0x8(%ebp),%eax
     728:	89 44 24 08          	mov    %eax,0x8(%esp)
     72c:	c7 44 24 04 e7 14 00 	movl   $0x14e7,0x4(%esp)
     733:	00 
     734:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
     73b:	e8 78 09 00 00       	call   10b8 <printf>
    panic("syntax");
     740:	c7 04 24 f6 14 00 00 	movl   $0x14f6,(%esp)
     747:	e8 05 fc ff ff       	call   351 <panic>
  }
  nulterminate(cmd);
     74c:	8b 45 f0             	mov    -0x10(%ebp),%eax
     74f:	89 04 24             	mov    %eax,(%esp)
     752:	e8 a4 04 00 00       	call   bfb <nulterminate>
  return cmd;
     757:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     75a:	83 c4 24             	add    $0x24,%esp
     75d:	5b                   	pop    %ebx
     75e:	5d                   	pop    %ebp
     75f:	c3                   	ret    

00000760 <parseline>:

struct cmd*
parseline(char **ps, char *es)
{
     760:	55                   	push   %ebp
     761:	89 e5                	mov    %esp,%ebp
     763:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
     766:	8b 45 0c             	mov    0xc(%ebp),%eax
     769:	89 44 24 04          	mov    %eax,0x4(%esp)
     76d:	8b 45 08             	mov    0x8(%ebp),%eax
     770:	89 04 24             	mov    %eax,(%esp)
     773:	e8 bc 00 00 00       	call   834 <parsepipe>
     778:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(peek(ps, es, "&")){
     77b:	eb 30                	jmp    7ad <parseline+0x4d>
    gettoken(ps, es, 0, 0);
     77d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     784:	00 
     785:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     78c:	00 
     78d:	8b 45 0c             	mov    0xc(%ebp),%eax
     790:	89 44 24 04          	mov    %eax,0x4(%esp)
     794:	8b 45 08             	mov    0x8(%ebp),%eax
     797:	89 04 24             	mov    %eax,(%esp)
     79a:	e8 8d fd ff ff       	call   52c <gettoken>
    cmd = backcmd(cmd);
     79f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7a2:	89 04 24             	mov    %eax,(%esp)
     7a5:	e8 3b fd ff ff       	call   4e5 <backcmd>
     7aa:	89 45 f4             	mov    %eax,-0xc(%ebp)
parseline(char **ps, char *es)
{
  struct cmd *cmd;

  cmd = parsepipe(ps, es);
  while(peek(ps, es, "&")){
     7ad:	c7 44 24 08 fd 14 00 	movl   $0x14fd,0x8(%esp)
     7b4:	00 
     7b5:	8b 45 0c             	mov    0xc(%ebp),%eax
     7b8:	89 44 24 04          	mov    %eax,0x4(%esp)
     7bc:	8b 45 08             	mov    0x8(%ebp),%eax
     7bf:	89 04 24             	mov    %eax,(%esp)
     7c2:	e8 9c fe ff ff       	call   663 <peek>
     7c7:	85 c0                	test   %eax,%eax
     7c9:	75 b2                	jne    77d <parseline+0x1d>
    gettoken(ps, es, 0, 0);
    cmd = backcmd(cmd);
  }
  if(peek(ps, es, ";")){
     7cb:	c7 44 24 08 ff 14 00 	movl   $0x14ff,0x8(%esp)
     7d2:	00 
     7d3:	8b 45 0c             	mov    0xc(%ebp),%eax
     7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
     7da:	8b 45 08             	mov    0x8(%ebp),%eax
     7dd:	89 04 24             	mov    %eax,(%esp)
     7e0:	e8 7e fe ff ff       	call   663 <peek>
     7e5:	85 c0                	test   %eax,%eax
     7e7:	74 46                	je     82f <parseline+0xcf>
    gettoken(ps, es, 0, 0);
     7e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     7f0:	00 
     7f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     7f8:	00 
     7f9:	8b 45 0c             	mov    0xc(%ebp),%eax
     7fc:	89 44 24 04          	mov    %eax,0x4(%esp)
     800:	8b 45 08             	mov    0x8(%ebp),%eax
     803:	89 04 24             	mov    %eax,(%esp)
     806:	e8 21 fd ff ff       	call   52c <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     80b:	8b 45 0c             	mov    0xc(%ebp),%eax
     80e:	89 44 24 04          	mov    %eax,0x4(%esp)
     812:	8b 45 08             	mov    0x8(%ebp),%eax
     815:	89 04 24             	mov    %eax,(%esp)
     818:	e8 43 ff ff ff       	call   760 <parseline>
     81d:	89 44 24 04          	mov    %eax,0x4(%esp)
     821:	8b 45 f4             	mov    -0xc(%ebp),%eax
     824:	89 04 24             	mov    %eax,(%esp)
     827:	e8 69 fc ff ff       	call   495 <listcmd>
     82c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     82f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     832:	c9                   	leave  
     833:	c3                   	ret    

00000834 <parsepipe>:

struct cmd*
parsepipe(char **ps, char *es)
{
     834:	55                   	push   %ebp
     835:	89 e5                	mov    %esp,%ebp
     837:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  cmd = parseexec(ps, es);
     83a:	8b 45 0c             	mov    0xc(%ebp),%eax
     83d:	89 44 24 04          	mov    %eax,0x4(%esp)
     841:	8b 45 08             	mov    0x8(%ebp),%eax
     844:	89 04 24             	mov    %eax,(%esp)
     847:	e8 68 02 00 00       	call   ab4 <parseexec>
     84c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(peek(ps, es, "|")){
     84f:	c7 44 24 08 01 15 00 	movl   $0x1501,0x8(%esp)
     856:	00 
     857:	8b 45 0c             	mov    0xc(%ebp),%eax
     85a:	89 44 24 04          	mov    %eax,0x4(%esp)
     85e:	8b 45 08             	mov    0x8(%ebp),%eax
     861:	89 04 24             	mov    %eax,(%esp)
     864:	e8 fa fd ff ff       	call   663 <peek>
     869:	85 c0                	test   %eax,%eax
     86b:	74 46                	je     8b3 <parsepipe+0x7f>
    gettoken(ps, es, 0, 0);
     86d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     874:	00 
     875:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     87c:	00 
     87d:	8b 45 0c             	mov    0xc(%ebp),%eax
     880:	89 44 24 04          	mov    %eax,0x4(%esp)
     884:	8b 45 08             	mov    0x8(%ebp),%eax
     887:	89 04 24             	mov    %eax,(%esp)
     88a:	e8 9d fc ff ff       	call   52c <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     88f:	8b 45 0c             	mov    0xc(%ebp),%eax
     892:	89 44 24 04          	mov    %eax,0x4(%esp)
     896:	8b 45 08             	mov    0x8(%ebp),%eax
     899:	89 04 24             	mov    %eax,(%esp)
     89c:	e8 93 ff ff ff       	call   834 <parsepipe>
     8a1:	89 44 24 04          	mov    %eax,0x4(%esp)
     8a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
     8a8:	89 04 24             	mov    %eax,(%esp)
     8ab:	e8 95 fb ff ff       	call   445 <pipecmd>
     8b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }
  return cmd;
     8b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     8b6:	c9                   	leave  
     8b7:	c3                   	ret    

000008b8 <parseredirs>:

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     8b8:	55                   	push   %ebp
     8b9:	89 e5                	mov    %esp,%ebp
     8bb:	83 ec 38             	sub    $0x38,%esp
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     8be:	e9 f6 00 00 00       	jmp    9b9 <parseredirs+0x101>
    tok = gettoken(ps, es, 0, 0);
     8c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     8ca:	00 
     8cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     8d2:	00 
     8d3:	8b 45 10             	mov    0x10(%ebp),%eax
     8d6:	89 44 24 04          	mov    %eax,0x4(%esp)
     8da:	8b 45 0c             	mov    0xc(%ebp),%eax
     8dd:	89 04 24             	mov    %eax,(%esp)
     8e0:	e8 47 fc ff ff       	call   52c <gettoken>
     8e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(gettoken(ps, es, &q, &eq) != 'a')
     8e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
     8eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
     8ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
     8f2:	89 44 24 08          	mov    %eax,0x8(%esp)
     8f6:	8b 45 10             	mov    0x10(%ebp),%eax
     8f9:	89 44 24 04          	mov    %eax,0x4(%esp)
     8fd:	8b 45 0c             	mov    0xc(%ebp),%eax
     900:	89 04 24             	mov    %eax,(%esp)
     903:	e8 24 fc ff ff       	call   52c <gettoken>
     908:	83 f8 61             	cmp    $0x61,%eax
     90b:	74 0c                	je     919 <parseredirs+0x61>
      panic("missing file for redirection");
     90d:	c7 04 24 03 15 00 00 	movl   $0x1503,(%esp)
     914:	e8 38 fa ff ff       	call   351 <panic>
    switch(tok){
     919:	8b 45 f4             	mov    -0xc(%ebp),%eax
     91c:	83 f8 3c             	cmp    $0x3c,%eax
     91f:	74 0f                	je     930 <parseredirs+0x78>
     921:	83 f8 3e             	cmp    $0x3e,%eax
     924:	74 38                	je     95e <parseredirs+0xa6>
     926:	83 f8 2b             	cmp    $0x2b,%eax
     929:	74 61                	je     98c <parseredirs+0xd4>
     92b:	e9 89 00 00 00       	jmp    9b9 <parseredirs+0x101>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     930:	8b 55 ec             	mov    -0x14(%ebp),%edx
     933:	8b 45 f0             	mov    -0x10(%ebp),%eax
     936:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
     93d:	00 
     93e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     945:	00 
     946:	89 54 24 08          	mov    %edx,0x8(%esp)
     94a:	89 44 24 04          	mov    %eax,0x4(%esp)
     94e:	8b 45 08             	mov    0x8(%ebp),%eax
     951:	89 04 24             	mov    %eax,(%esp)
     954:	e8 81 fa ff ff       	call   3da <redircmd>
     959:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     95c:	eb 5b                	jmp    9b9 <parseredirs+0x101>
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     95e:	8b 55 ec             	mov    -0x14(%ebp),%edx
     961:	8b 45 f0             	mov    -0x10(%ebp),%eax
     964:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     96b:	00 
     96c:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     973:	00 
     974:	89 54 24 08          	mov    %edx,0x8(%esp)
     978:	89 44 24 04          	mov    %eax,0x4(%esp)
     97c:	8b 45 08             	mov    0x8(%ebp),%eax
     97f:	89 04 24             	mov    %eax,(%esp)
     982:	e8 53 fa ff ff       	call   3da <redircmd>
     987:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     98a:	eb 2d                	jmp    9b9 <parseredirs+0x101>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     98c:	8b 55 ec             	mov    -0x14(%ebp),%edx
     98f:	8b 45 f0             	mov    -0x10(%ebp),%eax
     992:	c7 44 24 10 01 00 00 	movl   $0x1,0x10(%esp)
     999:	00 
     99a:	c7 44 24 0c 01 02 00 	movl   $0x201,0xc(%esp)
     9a1:	00 
     9a2:	89 54 24 08          	mov    %edx,0x8(%esp)
     9a6:	89 44 24 04          	mov    %eax,0x4(%esp)
     9aa:	8b 45 08             	mov    0x8(%ebp),%eax
     9ad:	89 04 24             	mov    %eax,(%esp)
     9b0:	e8 25 fa ff ff       	call   3da <redircmd>
     9b5:	89 45 08             	mov    %eax,0x8(%ebp)
      break;
     9b8:	90                   	nop
parseredirs(struct cmd *cmd, char **ps, char *es)
{
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     9b9:	c7 44 24 08 20 15 00 	movl   $0x1520,0x8(%esp)
     9c0:	00 
     9c1:	8b 45 10             	mov    0x10(%ebp),%eax
     9c4:	89 44 24 04          	mov    %eax,0x4(%esp)
     9c8:	8b 45 0c             	mov    0xc(%ebp),%eax
     9cb:	89 04 24             	mov    %eax,(%esp)
     9ce:	e8 90 fc ff ff       	call   663 <peek>
     9d3:	85 c0                	test   %eax,%eax
     9d5:	0f 85 e8 fe ff ff    	jne    8c3 <parseredirs+0xb>
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
      break;
    }
  }
  return cmd;
     9db:	8b 45 08             	mov    0x8(%ebp),%eax
}
     9de:	c9                   	leave  
     9df:	c3                   	ret    

000009e0 <parseblock>:

struct cmd*
parseblock(char **ps, char *es)
{
     9e0:	55                   	push   %ebp
     9e1:	89 e5                	mov    %esp,%ebp
     9e3:	83 ec 28             	sub    $0x28,%esp
  struct cmd *cmd;

  if(!peek(ps, es, "("))
     9e6:	c7 44 24 08 23 15 00 	movl   $0x1523,0x8(%esp)
     9ed:	00 
     9ee:	8b 45 0c             	mov    0xc(%ebp),%eax
     9f1:	89 44 24 04          	mov    %eax,0x4(%esp)
     9f5:	8b 45 08             	mov    0x8(%ebp),%eax
     9f8:	89 04 24             	mov    %eax,(%esp)
     9fb:	e8 63 fc ff ff       	call   663 <peek>
     a00:	85 c0                	test   %eax,%eax
     a02:	75 0c                	jne    a10 <parseblock+0x30>
    panic("parseblock");
     a04:	c7 04 24 25 15 00 00 	movl   $0x1525,(%esp)
     a0b:	e8 41 f9 ff ff       	call   351 <panic>
  gettoken(ps, es, 0, 0);
     a10:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a17:	00 
     a18:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a1f:	00 
     a20:	8b 45 0c             	mov    0xc(%ebp),%eax
     a23:	89 44 24 04          	mov    %eax,0x4(%esp)
     a27:	8b 45 08             	mov    0x8(%ebp),%eax
     a2a:	89 04 24             	mov    %eax,(%esp)
     a2d:	e8 fa fa ff ff       	call   52c <gettoken>
  cmd = parseline(ps, es);
     a32:	8b 45 0c             	mov    0xc(%ebp),%eax
     a35:	89 44 24 04          	mov    %eax,0x4(%esp)
     a39:	8b 45 08             	mov    0x8(%ebp),%eax
     a3c:	89 04 24             	mov    %eax,(%esp)
     a3f:	e8 1c fd ff ff       	call   760 <parseline>
     a44:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!peek(ps, es, ")"))
     a47:	c7 44 24 08 30 15 00 	movl   $0x1530,0x8(%esp)
     a4e:	00 
     a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
     a52:	89 44 24 04          	mov    %eax,0x4(%esp)
     a56:	8b 45 08             	mov    0x8(%ebp),%eax
     a59:	89 04 24             	mov    %eax,(%esp)
     a5c:	e8 02 fc ff ff       	call   663 <peek>
     a61:	85 c0                	test   %eax,%eax
     a63:	75 0c                	jne    a71 <parseblock+0x91>
    panic("syntax - missing )");
     a65:	c7 04 24 32 15 00 00 	movl   $0x1532,(%esp)
     a6c:	e8 e0 f8 ff ff       	call   351 <panic>
  gettoken(ps, es, 0, 0);
     a71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
     a78:	00 
     a79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
     a80:	00 
     a81:	8b 45 0c             	mov    0xc(%ebp),%eax
     a84:	89 44 24 04          	mov    %eax,0x4(%esp)
     a88:	8b 45 08             	mov    0x8(%ebp),%eax
     a8b:	89 04 24             	mov    %eax,(%esp)
     a8e:	e8 99 fa ff ff       	call   52c <gettoken>
  cmd = parseredirs(cmd, ps, es);
     a93:	8b 45 0c             	mov    0xc(%ebp),%eax
     a96:	89 44 24 08          	mov    %eax,0x8(%esp)
     a9a:	8b 45 08             	mov    0x8(%ebp),%eax
     a9d:	89 44 24 04          	mov    %eax,0x4(%esp)
     aa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     aa4:	89 04 24             	mov    %eax,(%esp)
     aa7:	e8 0c fe ff ff       	call   8b8 <parseredirs>
     aac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return cmd;
     aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
     ab2:	c9                   	leave  
     ab3:	c3                   	ret    

00000ab4 <parseexec>:

struct cmd*
parseexec(char **ps, char *es)
{
     ab4:	55                   	push   %ebp
     ab5:	89 e5                	mov    %esp,%ebp
     ab7:	83 ec 38             	sub    $0x38,%esp
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;
  
  if(peek(ps, es, "("))
     aba:	c7 44 24 08 23 15 00 	movl   $0x1523,0x8(%esp)
     ac1:	00 
     ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
     ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
     ac9:	8b 45 08             	mov    0x8(%ebp),%eax
     acc:	89 04 24             	mov    %eax,(%esp)
     acf:	e8 8f fb ff ff       	call   663 <peek>
     ad4:	85 c0                	test   %eax,%eax
     ad6:	74 17                	je     aef <parseexec+0x3b>
    return parseblock(ps, es);
     ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
     adb:	89 44 24 04          	mov    %eax,0x4(%esp)
     adf:	8b 45 08             	mov    0x8(%ebp),%eax
     ae2:	89 04 24             	mov    %eax,(%esp)
     ae5:	e8 f6 fe ff ff       	call   9e0 <parseblock>
     aea:	e9 0a 01 00 00       	jmp    bf9 <parseexec+0x145>

  ret = execcmd();
     aef:	e8 a8 f8 ff ff       	call   39c <execcmd>
     af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cmd = (struct execcmd*)ret;
     af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
     afa:	89 45 ec             	mov    %eax,-0x14(%ebp)

  argc = 0;
     afd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  ret = parseredirs(ret, ps, es);
     b04:	8b 45 0c             	mov    0xc(%ebp),%eax
     b07:	89 44 24 08          	mov    %eax,0x8(%esp)
     b0b:	8b 45 08             	mov    0x8(%ebp),%eax
     b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
     b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
     b15:	89 04 24             	mov    %eax,(%esp)
     b18:	e8 9b fd ff ff       	call   8b8 <parseredirs>
     b1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while(!peek(ps, es, "|)&;")){
     b20:	e9 8d 00 00 00       	jmp    bb2 <parseexec+0xfe>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     b25:	8d 45 e0             	lea    -0x20(%ebp),%eax
     b28:	89 44 24 0c          	mov    %eax,0xc(%esp)
     b2c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b2f:	89 44 24 08          	mov    %eax,0x8(%esp)
     b33:	8b 45 0c             	mov    0xc(%ebp),%eax
     b36:	89 44 24 04          	mov    %eax,0x4(%esp)
     b3a:	8b 45 08             	mov    0x8(%ebp),%eax
     b3d:	89 04 24             	mov    %eax,(%esp)
     b40:	e8 e7 f9 ff ff       	call   52c <gettoken>
     b45:	89 45 e8             	mov    %eax,-0x18(%ebp)
     b48:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     b4c:	0f 84 84 00 00 00    	je     bd6 <parseexec+0x122>
      break;
    if(tok != 'a')
     b52:	83 7d e8 61          	cmpl   $0x61,-0x18(%ebp)
     b56:	74 0c                	je     b64 <parseexec+0xb0>
      panic("syntax");
     b58:	c7 04 24 f6 14 00 00 	movl   $0x14f6,(%esp)
     b5f:	e8 ed f7 ff ff       	call   351 <panic>
    cmd->argv[argc] = q;
     b64:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
     b67:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     b6d:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
    cmd->eargv[argc] = eq;
     b71:	8b 55 e0             	mov    -0x20(%ebp),%edx
     b74:	8b 45 ec             	mov    -0x14(%ebp),%eax
     b77:	8b 4d f4             	mov    -0xc(%ebp),%ecx
     b7a:	83 c1 08             	add    $0x8,%ecx
     b7d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    argc++;
     b81:	ff 45 f4             	incl   -0xc(%ebp)
    if(argc >= MAXARGS)
     b84:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
     b88:	7e 0c                	jle    b96 <parseexec+0xe2>
      panic("too many args");
     b8a:	c7 04 24 45 15 00 00 	movl   $0x1545,(%esp)
     b91:	e8 bb f7 ff ff       	call   351 <panic>
    ret = parseredirs(ret, ps, es);
     b96:	8b 45 0c             	mov    0xc(%ebp),%eax
     b99:	89 44 24 08          	mov    %eax,0x8(%esp)
     b9d:	8b 45 08             	mov    0x8(%ebp),%eax
     ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
     ba4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ba7:	89 04 24             	mov    %eax,(%esp)
     baa:	e8 09 fd ff ff       	call   8b8 <parseredirs>
     baf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ret = execcmd();
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
  while(!peek(ps, es, "|)&;")){
     bb2:	c7 44 24 08 53 15 00 	movl   $0x1553,0x8(%esp)
     bb9:	00 
     bba:	8b 45 0c             	mov    0xc(%ebp),%eax
     bbd:	89 44 24 04          	mov    %eax,0x4(%esp)
     bc1:	8b 45 08             	mov    0x8(%ebp),%eax
     bc4:	89 04 24             	mov    %eax,(%esp)
     bc7:	e8 97 fa ff ff       	call   663 <peek>
     bcc:	85 c0                	test   %eax,%eax
     bce:	0f 84 51 ff ff ff    	je     b25 <parseexec+0x71>
     bd4:	eb 01                	jmp    bd7 <parseexec+0x123>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
     bd6:	90                   	nop
    argc++;
    if(argc >= MAXARGS)
      panic("too many args");
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
     bd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
     bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
     bdd:	c7 44 90 04 00 00 00 	movl   $0x0,0x4(%eax,%edx,4)
     be4:	00 
  cmd->eargv[argc] = 0;
     be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
     be8:	8b 55 f4             	mov    -0xc(%ebp),%edx
     beb:	83 c2 08             	add    $0x8,%edx
     bee:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
     bf5:	00 
  return ret;
     bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     bf9:	c9                   	leave  
     bfa:	c3                   	ret    

00000bfb <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     bfb:	55                   	push   %ebp
     bfc:	89 e5                	mov    %esp,%ebp
     bfe:	83 ec 38             	sub    $0x38,%esp
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     c01:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
     c05:	75 0a                	jne    c11 <nulterminate+0x16>
    return 0;
     c07:	b8 00 00 00 00       	mov    $0x0,%eax
     c0c:	e9 c8 00 00 00       	jmp    cd9 <nulterminate+0xde>
  
  switch(cmd->type){
     c11:	8b 45 08             	mov    0x8(%ebp),%eax
     c14:	8b 00                	mov    (%eax),%eax
     c16:	83 f8 05             	cmp    $0x5,%eax
     c19:	0f 87 b7 00 00 00    	ja     cd6 <nulterminate+0xdb>
     c1f:	8b 04 85 58 15 00 00 	mov    0x1558(,%eax,4),%eax
     c26:	ff e0                	jmp    *%eax
  case EXEC:
    ecmd = (struct execcmd*)cmd;
     c28:	8b 45 08             	mov    0x8(%ebp),%eax
     c2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(i=0; ecmd->argv[i]; i++)
     c2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     c35:	eb 13                	jmp    c4a <nulterminate+0x4f>
      *ecmd->eargv[i] = 0;
     c37:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c3d:	83 c2 08             	add    $0x8,%edx
     c40:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
     c44:	c6 00 00             	movb   $0x0,(%eax)
    return 0;
  
  switch(cmd->type){
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     c47:	ff 45 f4             	incl   -0xc(%ebp)
     c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
     c50:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
     c54:	85 c0                	test   %eax,%eax
     c56:	75 df                	jne    c37 <nulterminate+0x3c>
      *ecmd->eargv[i] = 0;
    break;
     c58:	eb 7c                	jmp    cd6 <nulterminate+0xdb>

  case REDIR:
    rcmd = (struct redircmd*)cmd;
     c5a:	8b 45 08             	mov    0x8(%ebp),%eax
     c5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    nulterminate(rcmd->cmd);
     c60:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c63:	8b 40 04             	mov    0x4(%eax),%eax
     c66:	89 04 24             	mov    %eax,(%esp)
     c69:	e8 8d ff ff ff       	call   bfb <nulterminate>
    *rcmd->efile = 0;
     c6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c71:	8b 40 0c             	mov    0xc(%eax),%eax
     c74:	c6 00 00             	movb   $0x0,(%eax)
    break;
     c77:	eb 5d                	jmp    cd6 <nulterminate+0xdb>

  case PIPE:
    pcmd = (struct pipecmd*)cmd;
     c79:	8b 45 08             	mov    0x8(%ebp),%eax
     c7c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nulterminate(pcmd->left);
     c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c82:	8b 40 04             	mov    0x4(%eax),%eax
     c85:	89 04 24             	mov    %eax,(%esp)
     c88:	e8 6e ff ff ff       	call   bfb <nulterminate>
    nulterminate(pcmd->right);
     c8d:	8b 45 e8             	mov    -0x18(%ebp),%eax
     c90:	8b 40 08             	mov    0x8(%eax),%eax
     c93:	89 04 24             	mov    %eax,(%esp)
     c96:	e8 60 ff ff ff       	call   bfb <nulterminate>
    break;
     c9b:	eb 39                	jmp    cd6 <nulterminate+0xdb>
    
  case LIST:
    lcmd = (struct listcmd*)cmd;
     c9d:	8b 45 08             	mov    0x8(%ebp),%eax
     ca0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nulterminate(lcmd->left);
     ca3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     ca6:	8b 40 04             	mov    0x4(%eax),%eax
     ca9:	89 04 24             	mov    %eax,(%esp)
     cac:	e8 4a ff ff ff       	call   bfb <nulterminate>
    nulterminate(lcmd->right);
     cb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     cb4:	8b 40 08             	mov    0x8(%eax),%eax
     cb7:	89 04 24             	mov    %eax,(%esp)
     cba:	e8 3c ff ff ff       	call   bfb <nulterminate>
    break;
     cbf:	eb 15                	jmp    cd6 <nulterminate+0xdb>

  case BACK:
    bcmd = (struct backcmd*)cmd;
     cc1:	8b 45 08             	mov    0x8(%ebp),%eax
     cc4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nulterminate(bcmd->cmd);
     cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
     cca:	8b 40 04             	mov    0x4(%eax),%eax
     ccd:	89 04 24             	mov    %eax,(%esp)
     cd0:	e8 26 ff ff ff       	call   bfb <nulterminate>
    break;
     cd5:	90                   	nop
  }
  return cmd;
     cd6:	8b 45 08             	mov    0x8(%ebp),%eax
}
     cd9:	c9                   	leave  
     cda:	c3                   	ret    
     cdb:	90                   	nop

00000cdc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
     cdc:	55                   	push   %ebp
     cdd:	89 e5                	mov    %esp,%ebp
     cdf:	57                   	push   %edi
     ce0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
     ce1:	8b 4d 08             	mov    0x8(%ebp),%ecx
     ce4:	8b 55 10             	mov    0x10(%ebp),%edx
     ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
     cea:	89 cb                	mov    %ecx,%ebx
     cec:	89 df                	mov    %ebx,%edi
     cee:	89 d1                	mov    %edx,%ecx
     cf0:	fc                   	cld    
     cf1:	f3 aa                	rep stos %al,%es:(%edi)
     cf3:	89 ca                	mov    %ecx,%edx
     cf5:	89 fb                	mov    %edi,%ebx
     cf7:	89 5d 08             	mov    %ebx,0x8(%ebp)
     cfa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
     cfd:	5b                   	pop    %ebx
     cfe:	5f                   	pop    %edi
     cff:	5d                   	pop    %ebp
     d00:	c3                   	ret    

00000d01 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
     d01:	55                   	push   %ebp
     d02:	89 e5                	mov    %esp,%ebp
     d04:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
     d07:	8b 45 08             	mov    0x8(%ebp),%eax
     d0a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
     d0d:	90                   	nop
     d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
     d11:	8a 10                	mov    (%eax),%dl
     d13:	8b 45 08             	mov    0x8(%ebp),%eax
     d16:	88 10                	mov    %dl,(%eax)
     d18:	8b 45 08             	mov    0x8(%ebp),%eax
     d1b:	8a 00                	mov    (%eax),%al
     d1d:	84 c0                	test   %al,%al
     d1f:	0f 95 c0             	setne  %al
     d22:	ff 45 08             	incl   0x8(%ebp)
     d25:	ff 45 0c             	incl   0xc(%ebp)
     d28:	84 c0                	test   %al,%al
     d2a:	75 e2                	jne    d0e <strcpy+0xd>
    ;
  return os;
     d2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d2f:	c9                   	leave  
     d30:	c3                   	ret    

00000d31 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     d31:	55                   	push   %ebp
     d32:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
     d34:	eb 06                	jmp    d3c <strcmp+0xb>
    p++, q++;
     d36:	ff 45 08             	incl   0x8(%ebp)
     d39:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
     d3c:	8b 45 08             	mov    0x8(%ebp),%eax
     d3f:	8a 00                	mov    (%eax),%al
     d41:	84 c0                	test   %al,%al
     d43:	74 0e                	je     d53 <strcmp+0x22>
     d45:	8b 45 08             	mov    0x8(%ebp),%eax
     d48:	8a 10                	mov    (%eax),%dl
     d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
     d4d:	8a 00                	mov    (%eax),%al
     d4f:	38 c2                	cmp    %al,%dl
     d51:	74 e3                	je     d36 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
     d53:	8b 45 08             	mov    0x8(%ebp),%eax
     d56:	8a 00                	mov    (%eax),%al
     d58:	0f b6 d0             	movzbl %al,%edx
     d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
     d5e:	8a 00                	mov    (%eax),%al
     d60:	0f b6 c0             	movzbl %al,%eax
     d63:	89 d1                	mov    %edx,%ecx
     d65:	29 c1                	sub    %eax,%ecx
     d67:	89 c8                	mov    %ecx,%eax
}
     d69:	5d                   	pop    %ebp
     d6a:	c3                   	ret    

00000d6b <strlen>:

uint
strlen(char *s)
{
     d6b:	55                   	push   %ebp
     d6c:	89 e5                	mov    %esp,%ebp
     d6e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
     d71:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
     d78:	eb 03                	jmp    d7d <strlen+0x12>
     d7a:	ff 45 fc             	incl   -0x4(%ebp)
     d7d:	8b 55 fc             	mov    -0x4(%ebp),%edx
     d80:	8b 45 08             	mov    0x8(%ebp),%eax
     d83:	01 d0                	add    %edx,%eax
     d85:	8a 00                	mov    (%eax),%al
     d87:	84 c0                	test   %al,%al
     d89:	75 ef                	jne    d7a <strlen+0xf>
    ;
  return n;
     d8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     d8e:	c9                   	leave  
     d8f:	c3                   	ret    

00000d90 <memset>:

void*
memset(void *dst, int c, uint n)
{
     d90:	55                   	push   %ebp
     d91:	89 e5                	mov    %esp,%ebp
     d93:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
     d96:	8b 45 10             	mov    0x10(%ebp),%eax
     d99:	89 44 24 08          	mov    %eax,0x8(%esp)
     d9d:	8b 45 0c             	mov    0xc(%ebp),%eax
     da0:	89 44 24 04          	mov    %eax,0x4(%esp)
     da4:	8b 45 08             	mov    0x8(%ebp),%eax
     da7:	89 04 24             	mov    %eax,(%esp)
     daa:	e8 2d ff ff ff       	call   cdc <stosb>
  return dst;
     daf:	8b 45 08             	mov    0x8(%ebp),%eax
}
     db2:	c9                   	leave  
     db3:	c3                   	ret    

00000db4 <strchr>:

char*
strchr(const char *s, char c)
{
     db4:	55                   	push   %ebp
     db5:	89 e5                	mov    %esp,%ebp
     db7:	83 ec 04             	sub    $0x4,%esp
     dba:	8b 45 0c             	mov    0xc(%ebp),%eax
     dbd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
     dc0:	eb 12                	jmp    dd4 <strchr+0x20>
    if(*s == c)
     dc2:	8b 45 08             	mov    0x8(%ebp),%eax
     dc5:	8a 00                	mov    (%eax),%al
     dc7:	3a 45 fc             	cmp    -0x4(%ebp),%al
     dca:	75 05                	jne    dd1 <strchr+0x1d>
      return (char*)s;
     dcc:	8b 45 08             	mov    0x8(%ebp),%eax
     dcf:	eb 11                	jmp    de2 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
     dd1:	ff 45 08             	incl   0x8(%ebp)
     dd4:	8b 45 08             	mov    0x8(%ebp),%eax
     dd7:	8a 00                	mov    (%eax),%al
     dd9:	84 c0                	test   %al,%al
     ddb:	75 e5                	jne    dc2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
     ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
     de2:	c9                   	leave  
     de3:	c3                   	ret    

00000de4 <gets>:

char*
gets(char *buf, int max)
{
     de4:	55                   	push   %ebp
     de5:	89 e5                	mov    %esp,%ebp
     de7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     dea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     df1:	eb 42                	jmp    e35 <gets+0x51>
    cc = read(0, &c, 1);
     df3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     dfa:	00 
     dfb:	8d 45 ef             	lea    -0x11(%ebp),%eax
     dfe:	89 44 24 04          	mov    %eax,0x4(%esp)
     e02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
     e09:	e8 32 01 00 00       	call   f40 <read>
     e0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
     e11:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     e15:	7e 29                	jle    e40 <gets+0x5c>
      break;
    buf[i++] = c;
     e17:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e1a:	8b 45 08             	mov    0x8(%ebp),%eax
     e1d:	01 c2                	add    %eax,%edx
     e1f:	8a 45 ef             	mov    -0x11(%ebp),%al
     e22:	88 02                	mov    %al,(%edx)
     e24:	ff 45 f4             	incl   -0xc(%ebp)
    if(c == '\n' || c == '\r')
     e27:	8a 45 ef             	mov    -0x11(%ebp),%al
     e2a:	3c 0a                	cmp    $0xa,%al
     e2c:	74 13                	je     e41 <gets+0x5d>
     e2e:	8a 45 ef             	mov    -0x11(%ebp),%al
     e31:	3c 0d                	cmp    $0xd,%al
     e33:	74 0c                	je     e41 <gets+0x5d>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e38:	40                   	inc    %eax
     e39:	3b 45 0c             	cmp    0xc(%ebp),%eax
     e3c:	7c b5                	jl     df3 <gets+0xf>
     e3e:	eb 01                	jmp    e41 <gets+0x5d>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
     e40:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
     e41:	8b 55 f4             	mov    -0xc(%ebp),%edx
     e44:	8b 45 08             	mov    0x8(%ebp),%eax
     e47:	01 d0                	add    %edx,%eax
     e49:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
     e4c:	8b 45 08             	mov    0x8(%ebp),%eax
}
     e4f:	c9                   	leave  
     e50:	c3                   	ret    

00000e51 <stat>:

int
stat(char *n, struct stat *st)
{
     e51:	55                   	push   %ebp
     e52:	89 e5                	mov    %esp,%ebp
     e54:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     e57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     e5e:	00 
     e5f:	8b 45 08             	mov    0x8(%ebp),%eax
     e62:	89 04 24             	mov    %eax,(%esp)
     e65:	e8 fe 00 00 00       	call   f68 <open>
     e6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
     e6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     e71:	79 07                	jns    e7a <stat+0x29>
    return -1;
     e73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
     e78:	eb 23                	jmp    e9d <stat+0x4c>
  r = fstat(fd, st);
     e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
     e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
     e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e84:	89 04 24             	mov    %eax,(%esp)
     e87:	e8 f4 00 00 00       	call   f80 <fstat>
     e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
     e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
     e92:	89 04 24             	mov    %eax,(%esp)
     e95:	e8 b6 00 00 00       	call   f50 <close>
  return r;
     e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
     e9d:	c9                   	leave  
     e9e:	c3                   	ret    

00000e9f <atoi>:

int
atoi(const char *s)
{
     e9f:	55                   	push   %ebp
     ea0:	89 e5                	mov    %esp,%ebp
     ea2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
     ea5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
     eac:	eb 21                	jmp    ecf <atoi+0x30>
    n = n*10 + *s++ - '0';
     eae:	8b 55 fc             	mov    -0x4(%ebp),%edx
     eb1:	89 d0                	mov    %edx,%eax
     eb3:	c1 e0 02             	shl    $0x2,%eax
     eb6:	01 d0                	add    %edx,%eax
     eb8:	d1 e0                	shl    %eax
     eba:	89 c2                	mov    %eax,%edx
     ebc:	8b 45 08             	mov    0x8(%ebp),%eax
     ebf:	8a 00                	mov    (%eax),%al
     ec1:	0f be c0             	movsbl %al,%eax
     ec4:	01 d0                	add    %edx,%eax
     ec6:	83 e8 30             	sub    $0x30,%eax
     ec9:	89 45 fc             	mov    %eax,-0x4(%ebp)
     ecc:	ff 45 08             	incl   0x8(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     ecf:	8b 45 08             	mov    0x8(%ebp),%eax
     ed2:	8a 00                	mov    (%eax),%al
     ed4:	3c 2f                	cmp    $0x2f,%al
     ed6:	7e 09                	jle    ee1 <atoi+0x42>
     ed8:	8b 45 08             	mov    0x8(%ebp),%eax
     edb:	8a 00                	mov    (%eax),%al
     edd:	3c 39                	cmp    $0x39,%al
     edf:	7e cd                	jle    eae <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
     ee1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
     ee4:	c9                   	leave  
     ee5:	c3                   	ret    

00000ee6 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
     ee6:	55                   	push   %ebp
     ee7:	89 e5                	mov    %esp,%ebp
     ee9:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
     eec:	8b 45 08             	mov    0x8(%ebp),%eax
     eef:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
     ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
     ef5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
     ef8:	eb 10                	jmp    f0a <memmove+0x24>
    *dst++ = *src++;
     efa:	8b 45 f8             	mov    -0x8(%ebp),%eax
     efd:	8a 10                	mov    (%eax),%dl
     eff:	8b 45 fc             	mov    -0x4(%ebp),%eax
     f02:	88 10                	mov    %dl,(%eax)
     f04:	ff 45 fc             	incl   -0x4(%ebp)
     f07:	ff 45 f8             	incl   -0x8(%ebp)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     f0a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
     f0e:	0f 9f c0             	setg   %al
     f11:	ff 4d 10             	decl   0x10(%ebp)
     f14:	84 c0                	test   %al,%al
     f16:	75 e2                	jne    efa <memmove+0x14>
    *dst++ = *src++;
  return vdst;
     f18:	8b 45 08             	mov    0x8(%ebp),%eax
}
     f1b:	c9                   	leave  
     f1c:	c3                   	ret    
     f1d:	66 90                	xchg   %ax,%ax
     f1f:	90                   	nop

00000f20 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
     f20:	b8 01 00 00 00       	mov    $0x1,%eax
     f25:	cd 40                	int    $0x40
     f27:	c3                   	ret    

00000f28 <exit>:
SYSCALL(exit)
     f28:	b8 02 00 00 00       	mov    $0x2,%eax
     f2d:	cd 40                	int    $0x40
     f2f:	c3                   	ret    

00000f30 <wait>:
SYSCALL(wait)
     f30:	b8 03 00 00 00       	mov    $0x3,%eax
     f35:	cd 40                	int    $0x40
     f37:	c3                   	ret    

00000f38 <pipe>:
SYSCALL(pipe)
     f38:	b8 04 00 00 00       	mov    $0x4,%eax
     f3d:	cd 40                	int    $0x40
     f3f:	c3                   	ret    

00000f40 <read>:
SYSCALL(read)
     f40:	b8 05 00 00 00       	mov    $0x5,%eax
     f45:	cd 40                	int    $0x40
     f47:	c3                   	ret    

00000f48 <write>:
SYSCALL(write)
     f48:	b8 10 00 00 00       	mov    $0x10,%eax
     f4d:	cd 40                	int    $0x40
     f4f:	c3                   	ret    

00000f50 <close>:
SYSCALL(close)
     f50:	b8 15 00 00 00       	mov    $0x15,%eax
     f55:	cd 40                	int    $0x40
     f57:	c3                   	ret    

00000f58 <kill>:
SYSCALL(kill)
     f58:	b8 06 00 00 00       	mov    $0x6,%eax
     f5d:	cd 40                	int    $0x40
     f5f:	c3                   	ret    

00000f60 <exec>:
SYSCALL(exec)
     f60:	b8 07 00 00 00       	mov    $0x7,%eax
     f65:	cd 40                	int    $0x40
     f67:	c3                   	ret    

00000f68 <open>:
SYSCALL(open)
     f68:	b8 0f 00 00 00       	mov    $0xf,%eax
     f6d:	cd 40                	int    $0x40
     f6f:	c3                   	ret    

00000f70 <mknod>:
SYSCALL(mknod)
     f70:	b8 11 00 00 00       	mov    $0x11,%eax
     f75:	cd 40                	int    $0x40
     f77:	c3                   	ret    

00000f78 <unlink>:
SYSCALL(unlink)
     f78:	b8 12 00 00 00       	mov    $0x12,%eax
     f7d:	cd 40                	int    $0x40
     f7f:	c3                   	ret    

00000f80 <fstat>:
SYSCALL(fstat)
     f80:	b8 08 00 00 00       	mov    $0x8,%eax
     f85:	cd 40                	int    $0x40
     f87:	c3                   	ret    

00000f88 <link>:
SYSCALL(link)
     f88:	b8 13 00 00 00       	mov    $0x13,%eax
     f8d:	cd 40                	int    $0x40
     f8f:	c3                   	ret    

00000f90 <mkdir>:
SYSCALL(mkdir)
     f90:	b8 14 00 00 00       	mov    $0x14,%eax
     f95:	cd 40                	int    $0x40
     f97:	c3                   	ret    

00000f98 <chdir>:
SYSCALL(chdir)
     f98:	b8 09 00 00 00       	mov    $0x9,%eax
     f9d:	cd 40                	int    $0x40
     f9f:	c3                   	ret    

00000fa0 <dup>:
SYSCALL(dup)
     fa0:	b8 0a 00 00 00       	mov    $0xa,%eax
     fa5:	cd 40                	int    $0x40
     fa7:	c3                   	ret    

00000fa8 <getpid>:
SYSCALL(getpid)
     fa8:	b8 0b 00 00 00       	mov    $0xb,%eax
     fad:	cd 40                	int    $0x40
     faf:	c3                   	ret    

00000fb0 <sbrk>:
SYSCALL(sbrk)
     fb0:	b8 0c 00 00 00       	mov    $0xc,%eax
     fb5:	cd 40                	int    $0x40
     fb7:	c3                   	ret    

00000fb8 <sleep>:
SYSCALL(sleep)
     fb8:	b8 0d 00 00 00       	mov    $0xd,%eax
     fbd:	cd 40                	int    $0x40
     fbf:	c3                   	ret    

00000fc0 <uptime>:
SYSCALL(uptime)
     fc0:	b8 0e 00 00 00       	mov    $0xe,%eax
     fc5:	cd 40                	int    $0x40
     fc7:	c3                   	ret    

00000fc8 <getppid>:
SYSCALL(getppid)        // USER DEFINED SYS CALL
     fc8:	b8 16 00 00 00       	mov    $0x16,%eax
     fcd:	cd 40                	int    $0x40
     fcf:	c3                   	ret    

00000fd0 <icount>:
SYSCALL(icount)         // USER DEFINED SYS CALL
     fd0:	b8 17 00 00 00       	mov    $0x17,%eax
     fd5:	cd 40                	int    $0x40
     fd7:	c3                   	ret    

00000fd8 <signal>:
SYSCALL(signal)         // USER DEFINED SYS CALL
     fd8:	b8 18 00 00 00       	mov    $0x18,%eax
     fdd:	cd 40                	int    $0x40
     fdf:	c3                   	ret    

00000fe0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
     fe0:	55                   	push   %ebp
     fe1:	89 e5                	mov    %esp,%ebp
     fe3:	83 ec 28             	sub    $0x28,%esp
     fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
     fe9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
     fec:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     ff3:	00 
     ff4:	8d 45 f4             	lea    -0xc(%ebp),%eax
     ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
     ffb:	8b 45 08             	mov    0x8(%ebp),%eax
     ffe:	89 04 24             	mov    %eax,(%esp)
    1001:	e8 42 ff ff ff       	call   f48 <write>
}
    1006:	c9                   	leave  
    1007:	c3                   	ret    

00001008 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    1008:	55                   	push   %ebp
    1009:	89 e5                	mov    %esp,%ebp
    100b:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    100e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    1015:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    1019:	74 17                	je     1032 <printint+0x2a>
    101b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    101f:	79 11                	jns    1032 <printint+0x2a>
    neg = 1;
    1021:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    1028:	8b 45 0c             	mov    0xc(%ebp),%eax
    102b:	f7 d8                	neg    %eax
    102d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1030:	eb 06                	jmp    1038 <printint+0x30>
  } else {
    x = xx;
    1032:	8b 45 0c             	mov    0xc(%ebp),%eax
    1035:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    1038:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    103f:	8b 4d 10             	mov    0x10(%ebp),%ecx
    1042:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1045:	ba 00 00 00 00       	mov    $0x0,%edx
    104a:	f7 f1                	div    %ecx
    104c:	89 d0                	mov    %edx,%eax
    104e:	8a 80 00 1a 00 00    	mov    0x1a00(%eax),%al
    1054:	8d 4d dc             	lea    -0x24(%ebp),%ecx
    1057:	8b 55 f4             	mov    -0xc(%ebp),%edx
    105a:	01 ca                	add    %ecx,%edx
    105c:	88 02                	mov    %al,(%edx)
    105e:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
    1061:	8b 55 10             	mov    0x10(%ebp),%edx
    1064:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    1067:	8b 45 ec             	mov    -0x14(%ebp),%eax
    106a:	ba 00 00 00 00       	mov    $0x0,%edx
    106f:	f7 75 d4             	divl   -0x2c(%ebp)
    1072:	89 45 ec             	mov    %eax,-0x14(%ebp)
    1075:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1079:	75 c4                	jne    103f <printint+0x37>
  if(neg)
    107b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    107f:	74 2c                	je     10ad <printint+0xa5>
    buf[i++] = '-';
    1081:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1084:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1087:	01 d0                	add    %edx,%eax
    1089:	c6 00 2d             	movb   $0x2d,(%eax)
    108c:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
    108f:	eb 1c                	jmp    10ad <printint+0xa5>
    putc(fd, buf[i]);
    1091:	8d 55 dc             	lea    -0x24(%ebp),%edx
    1094:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1097:	01 d0                	add    %edx,%eax
    1099:	8a 00                	mov    (%eax),%al
    109b:	0f be c0             	movsbl %al,%eax
    109e:	89 44 24 04          	mov    %eax,0x4(%esp)
    10a2:	8b 45 08             	mov    0x8(%ebp),%eax
    10a5:	89 04 24             	mov    %eax,(%esp)
    10a8:	e8 33 ff ff ff       	call   fe0 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    10ad:	ff 4d f4             	decl   -0xc(%ebp)
    10b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    10b4:	79 db                	jns    1091 <printint+0x89>
    putc(fd, buf[i]);
}
    10b6:	c9                   	leave  
    10b7:	c3                   	ret    

000010b8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    10b8:	55                   	push   %ebp
    10b9:	89 e5                	mov    %esp,%ebp
    10bb:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    10be:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    10c5:	8d 45 0c             	lea    0xc(%ebp),%eax
    10c8:	83 c0 04             	add    $0x4,%eax
    10cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    10ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    10d5:	e9 78 01 00 00       	jmp    1252 <printf+0x19a>
    c = fmt[i] & 0xff;
    10da:	8b 55 0c             	mov    0xc(%ebp),%edx
    10dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
    10e0:	01 d0                	add    %edx,%eax
    10e2:	8a 00                	mov    (%eax),%al
    10e4:	0f be c0             	movsbl %al,%eax
    10e7:	25 ff 00 00 00       	and    $0xff,%eax
    10ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    10ef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    10f3:	75 2c                	jne    1121 <printf+0x69>
      if(c == '%'){
    10f5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    10f9:	75 0c                	jne    1107 <printf+0x4f>
        state = '%';
    10fb:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    1102:	e9 48 01 00 00       	jmp    124f <printf+0x197>
      } else {
        putc(fd, c);
    1107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    110a:	0f be c0             	movsbl %al,%eax
    110d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1111:	8b 45 08             	mov    0x8(%ebp),%eax
    1114:	89 04 24             	mov    %eax,(%esp)
    1117:	e8 c4 fe ff ff       	call   fe0 <putc>
    111c:	e9 2e 01 00 00       	jmp    124f <printf+0x197>
      }
    } else if(state == '%'){
    1121:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    1125:	0f 85 24 01 00 00    	jne    124f <printf+0x197>
      if(c == 'd'){
    112b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    112f:	75 2d                	jne    115e <printf+0xa6>
        printint(fd, *ap, 10, 1);
    1131:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1134:	8b 00                	mov    (%eax),%eax
    1136:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    113d:	00 
    113e:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1145:	00 
    1146:	89 44 24 04          	mov    %eax,0x4(%esp)
    114a:	8b 45 08             	mov    0x8(%ebp),%eax
    114d:	89 04 24             	mov    %eax,(%esp)
    1150:	e8 b3 fe ff ff       	call   1008 <printint>
        ap++;
    1155:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1159:	e9 ea 00 00 00       	jmp    1248 <printf+0x190>
      } else if(c == 'x' || c == 'p'){
    115e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    1162:	74 06                	je     116a <printf+0xb2>
    1164:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    1168:	75 2d                	jne    1197 <printf+0xdf>
        printint(fd, *ap, 16, 0);
    116a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    116d:	8b 00                	mov    (%eax),%eax
    116f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    1176:	00 
    1177:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    117e:	00 
    117f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1183:	8b 45 08             	mov    0x8(%ebp),%eax
    1186:	89 04 24             	mov    %eax,(%esp)
    1189:	e8 7a fe ff ff       	call   1008 <printint>
        ap++;
    118e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1192:	e9 b1 00 00 00       	jmp    1248 <printf+0x190>
      } else if(c == 's'){
    1197:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    119b:	75 43                	jne    11e0 <printf+0x128>
        s = (char*)*ap;
    119d:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11a0:	8b 00                	mov    (%eax),%eax
    11a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    11a5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    11a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    11ad:	75 25                	jne    11d4 <printf+0x11c>
          s = "(null)";
    11af:	c7 45 f4 70 15 00 00 	movl   $0x1570,-0xc(%ebp)
        while(*s != 0){
    11b6:	eb 1c                	jmp    11d4 <printf+0x11c>
          putc(fd, *s);
    11b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11bb:	8a 00                	mov    (%eax),%al
    11bd:	0f be c0             	movsbl %al,%eax
    11c0:	89 44 24 04          	mov    %eax,0x4(%esp)
    11c4:	8b 45 08             	mov    0x8(%ebp),%eax
    11c7:	89 04 24             	mov    %eax,(%esp)
    11ca:	e8 11 fe ff ff       	call   fe0 <putc>
          s++;
    11cf:	ff 45 f4             	incl   -0xc(%ebp)
    11d2:	eb 01                	jmp    11d5 <printf+0x11d>
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    11d4:	90                   	nop
    11d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    11d8:	8a 00                	mov    (%eax),%al
    11da:	84 c0                	test   %al,%al
    11dc:	75 da                	jne    11b8 <printf+0x100>
    11de:	eb 68                	jmp    1248 <printf+0x190>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    11e0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    11e4:	75 1d                	jne    1203 <printf+0x14b>
        putc(fd, *ap);
    11e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
    11e9:	8b 00                	mov    (%eax),%eax
    11eb:	0f be c0             	movsbl %al,%eax
    11ee:	89 44 24 04          	mov    %eax,0x4(%esp)
    11f2:	8b 45 08             	mov    0x8(%ebp),%eax
    11f5:	89 04 24             	mov    %eax,(%esp)
    11f8:	e8 e3 fd ff ff       	call   fe0 <putc>
        ap++;
    11fd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    1201:	eb 45                	jmp    1248 <printf+0x190>
      } else if(c == '%'){
    1203:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    1207:	75 17                	jne    1220 <printf+0x168>
        putc(fd, c);
    1209:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    120c:	0f be c0             	movsbl %al,%eax
    120f:	89 44 24 04          	mov    %eax,0x4(%esp)
    1213:	8b 45 08             	mov    0x8(%ebp),%eax
    1216:	89 04 24             	mov    %eax,(%esp)
    1219:	e8 c2 fd ff ff       	call   fe0 <putc>
    121e:	eb 28                	jmp    1248 <printf+0x190>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1220:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    1227:	00 
    1228:	8b 45 08             	mov    0x8(%ebp),%eax
    122b:	89 04 24             	mov    %eax,(%esp)
    122e:	e8 ad fd ff ff       	call   fe0 <putc>
        putc(fd, c);
    1233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1236:	0f be c0             	movsbl %al,%eax
    1239:	89 44 24 04          	mov    %eax,0x4(%esp)
    123d:	8b 45 08             	mov    0x8(%ebp),%eax
    1240:	89 04 24             	mov    %eax,(%esp)
    1243:	e8 98 fd ff ff       	call   fe0 <putc>
      }
      state = 0;
    1248:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    124f:	ff 45 f0             	incl   -0x10(%ebp)
    1252:	8b 55 0c             	mov    0xc(%ebp),%edx
    1255:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1258:	01 d0                	add    %edx,%eax
    125a:	8a 00                	mov    (%eax),%al
    125c:	84 c0                	test   %al,%al
    125e:	0f 85 76 fe ff ff    	jne    10da <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    1264:	c9                   	leave  
    1265:	c3                   	ret    
    1266:	66 90                	xchg   %ax,%ax

00001268 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1268:	55                   	push   %ebp
    1269:	89 e5                	mov    %esp,%ebp
    126b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    126e:	8b 45 08             	mov    0x8(%ebp),%eax
    1271:	83 e8 08             	sub    $0x8,%eax
    1274:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1277:	a1 8c 1a 00 00       	mov    0x1a8c,%eax
    127c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    127f:	eb 24                	jmp    12a5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1281:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1284:	8b 00                	mov    (%eax),%eax
    1286:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1289:	77 12                	ja     129d <free+0x35>
    128b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    128e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    1291:	77 24                	ja     12b7 <free+0x4f>
    1293:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1296:	8b 00                	mov    (%eax),%eax
    1298:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    129b:	77 1a                	ja     12b7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    129d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12a0:	8b 00                	mov    (%eax),%eax
    12a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    12a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12a8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    12ab:	76 d4                	jbe    1281 <free+0x19>
    12ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12b0:	8b 00                	mov    (%eax),%eax
    12b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    12b5:	76 ca                	jbe    1281 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    12b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12ba:	8b 40 04             	mov    0x4(%eax),%eax
    12bd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    12c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12c7:	01 c2                	add    %eax,%edx
    12c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12cc:	8b 00                	mov    (%eax),%eax
    12ce:	39 c2                	cmp    %eax,%edx
    12d0:	75 24                	jne    12f6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    12d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12d5:	8b 50 04             	mov    0x4(%eax),%edx
    12d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12db:	8b 00                	mov    (%eax),%eax
    12dd:	8b 40 04             	mov    0x4(%eax),%eax
    12e0:	01 c2                	add    %eax,%edx
    12e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12e5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    12e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12eb:	8b 00                	mov    (%eax),%eax
    12ed:	8b 10                	mov    (%eax),%edx
    12ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12f2:	89 10                	mov    %edx,(%eax)
    12f4:	eb 0a                	jmp    1300 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    12f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
    12f9:	8b 10                	mov    (%eax),%edx
    12fb:	8b 45 f8             	mov    -0x8(%ebp),%eax
    12fe:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    1300:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1303:	8b 40 04             	mov    0x4(%eax),%eax
    1306:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    130d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1310:	01 d0                	add    %edx,%eax
    1312:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    1315:	75 20                	jne    1337 <free+0xcf>
    p->s.size += bp->s.size;
    1317:	8b 45 fc             	mov    -0x4(%ebp),%eax
    131a:	8b 50 04             	mov    0x4(%eax),%edx
    131d:	8b 45 f8             	mov    -0x8(%ebp),%eax
    1320:	8b 40 04             	mov    0x4(%eax),%eax
    1323:	01 c2                	add    %eax,%edx
    1325:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1328:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    132b:	8b 45 f8             	mov    -0x8(%ebp),%eax
    132e:	8b 10                	mov    (%eax),%edx
    1330:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1333:	89 10                	mov    %edx,(%eax)
    1335:	eb 08                	jmp    133f <free+0xd7>
  } else
    p->s.ptr = bp;
    1337:	8b 45 fc             	mov    -0x4(%ebp),%eax
    133a:	8b 55 f8             	mov    -0x8(%ebp),%edx
    133d:	89 10                	mov    %edx,(%eax)
  freep = p;
    133f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    1342:	a3 8c 1a 00 00       	mov    %eax,0x1a8c
}
    1347:	c9                   	leave  
    1348:	c3                   	ret    

00001349 <morecore>:

static Header*
morecore(uint nu)
{
    1349:	55                   	push   %ebp
    134a:	89 e5                	mov    %esp,%ebp
    134c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    134f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    1356:	77 07                	ja     135f <morecore+0x16>
    nu = 4096;
    1358:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    135f:	8b 45 08             	mov    0x8(%ebp),%eax
    1362:	c1 e0 03             	shl    $0x3,%eax
    1365:	89 04 24             	mov    %eax,(%esp)
    1368:	e8 43 fc ff ff       	call   fb0 <sbrk>
    136d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    1370:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    1374:	75 07                	jne    137d <morecore+0x34>
    return 0;
    1376:	b8 00 00 00 00       	mov    $0x0,%eax
    137b:	eb 22                	jmp    139f <morecore+0x56>
  hp = (Header*)p;
    137d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1380:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    1383:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1386:	8b 55 08             	mov    0x8(%ebp),%edx
    1389:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    138f:	83 c0 08             	add    $0x8,%eax
    1392:	89 04 24             	mov    %eax,(%esp)
    1395:	e8 ce fe ff ff       	call   1268 <free>
  return freep;
    139a:	a1 8c 1a 00 00       	mov    0x1a8c,%eax
}
    139f:	c9                   	leave  
    13a0:	c3                   	ret    

000013a1 <malloc>:

void*
malloc(uint nbytes)
{
    13a1:	55                   	push   %ebp
    13a2:	89 e5                	mov    %esp,%ebp
    13a4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    13a7:	8b 45 08             	mov    0x8(%ebp),%eax
    13aa:	83 c0 07             	add    $0x7,%eax
    13ad:	c1 e8 03             	shr    $0x3,%eax
    13b0:	40                   	inc    %eax
    13b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    13b4:	a1 8c 1a 00 00       	mov    0x1a8c,%eax
    13b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    13bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    13c0:	75 23                	jne    13e5 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    13c2:	c7 45 f0 84 1a 00 00 	movl   $0x1a84,-0x10(%ebp)
    13c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13cc:	a3 8c 1a 00 00       	mov    %eax,0x1a8c
    13d1:	a1 8c 1a 00 00       	mov    0x1a8c,%eax
    13d6:	a3 84 1a 00 00       	mov    %eax,0x1a84
    base.s.size = 0;
    13db:	c7 05 88 1a 00 00 00 	movl   $0x0,0x1a88
    13e2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13e8:	8b 00                	mov    (%eax),%eax
    13ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    13ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13f0:	8b 40 04             	mov    0x4(%eax),%eax
    13f3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    13f6:	72 4d                	jb     1445 <malloc+0xa4>
      if(p->s.size == nunits)
    13f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13fb:	8b 40 04             	mov    0x4(%eax),%eax
    13fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    1401:	75 0c                	jne    140f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    1403:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1406:	8b 10                	mov    (%eax),%edx
    1408:	8b 45 f0             	mov    -0x10(%ebp),%eax
    140b:	89 10                	mov    %edx,(%eax)
    140d:	eb 26                	jmp    1435 <malloc+0x94>
      else {
        p->s.size -= nunits;
    140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1412:	8b 40 04             	mov    0x4(%eax),%eax
    1415:	89 c2                	mov    %eax,%edx
    1417:	2b 55 ec             	sub    -0x14(%ebp),%edx
    141a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    141d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    1420:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1423:	8b 40 04             	mov    0x4(%eax),%eax
    1426:	c1 e0 03             	shl    $0x3,%eax
    1429:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    142f:	8b 55 ec             	mov    -0x14(%ebp),%edx
    1432:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    1435:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1438:	a3 8c 1a 00 00       	mov    %eax,0x1a8c
      return (void*)(p + 1);
    143d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1440:	83 c0 08             	add    $0x8,%eax
    1443:	eb 38                	jmp    147d <malloc+0xdc>
    }
    if(p == freep)
    1445:	a1 8c 1a 00 00       	mov    0x1a8c,%eax
    144a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    144d:	75 1b                	jne    146a <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    144f:	8b 45 ec             	mov    -0x14(%ebp),%eax
    1452:	89 04 24             	mov    %eax,(%esp)
    1455:	e8 ef fe ff ff       	call   1349 <morecore>
    145a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    145d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1461:	75 07                	jne    146a <malloc+0xc9>
        return 0;
    1463:	b8 00 00 00 00       	mov    $0x0,%eax
    1468:	eb 13                	jmp    147d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    146d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    1470:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1473:	8b 00                	mov    (%eax),%eax
    1475:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    1478:	e9 70 ff ff ff       	jmp    13ed <malloc+0x4c>
}
    147d:	c9                   	leave  
    147e:	c3                   	ret    
