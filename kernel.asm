
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 c6 10 80       	mov    $0x8010c670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 97 33 10 80       	mov    $0x80103397,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 b8 81 10 	movl   $0x801081b8,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100049:	e8 bc 4a 00 00       	call   80104b0a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 b0 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb0
80100055:	db 10 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 b4 db 10 80 a4 	movl   $0x8010dba4,0x8010dbb4
8010005f:	db 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 b4 c6 10 80 	movl   $0x8010c6b4,-0xc(%ebp)
80100069:	eb 3a                	jmp    801000a5 <binit+0x71>
    b->next = bcache.head.next;
8010006b:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
    b->dev = -1;
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008b:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
80100090:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100093:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100096:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100099:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009e:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a5:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
801000ac:	72 bd                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ae:	c9                   	leave  
801000af:	c3                   	ret    

801000b0 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate fresh block.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b0:	55                   	push   %ebp
801000b1:	89 e5                	mov    %esp,%ebp
801000b3:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b6:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801000bd:	e8 69 4a 00 00       	call   80104b2b <acquire>

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c2:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
801000c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000ca:	eb 63                	jmp    8010012f <bget+0x7f>
    if(b->dev == dev && b->sector == sector){
801000cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000cf:	8b 40 04             	mov    0x4(%eax),%eax
801000d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801000d5:	75 4f                	jne    80100126 <bget+0x76>
801000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000da:	8b 40 08             	mov    0x8(%eax),%eax
801000dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e0:	75 44                	jne    80100126 <bget+0x76>
      if(!(b->flags & B_BUSY)){
801000e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e5:	8b 00                	mov    (%eax),%eax
801000e7:	83 e0 01             	and    $0x1,%eax
801000ea:	85 c0                	test   %eax,%eax
801000ec:	75 23                	jne    80100111 <bget+0x61>
        b->flags |= B_BUSY;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 00                	mov    (%eax),%eax
801000f3:	89 c2                	mov    %eax,%edx
801000f5:	83 ca 01             	or     $0x1,%edx
801000f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fb:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
801000fd:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
80100104:	e8 84 4a 00 00       	call   80104b8d <release>
        return b;
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	e9 93 00 00 00       	jmp    801001a4 <bget+0xf4>
      }
      sleep(b, &bcache.lock);
80100111:	c7 44 24 04 80 c6 10 	movl   $0x8010c680,0x4(%esp)
80100118:	80 
80100119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011c:	89 04 24             	mov    %eax,(%esp)
8010011f:	e8 df 46 00 00       	call   80104803 <sleep>
      goto loop;
80100124:	eb 9c                	jmp    801000c2 <bget+0x12>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100126:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100129:	8b 40 10             	mov    0x10(%eax),%eax
8010012c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010012f:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100136:	75 94                	jne    801000cc <bget+0x1c>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100138:	a1 b0 db 10 80       	mov    0x8010dbb0,%eax
8010013d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100140:	eb 4d                	jmp    8010018f <bget+0xdf>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100145:	8b 00                	mov    (%eax),%eax
80100147:	83 e0 01             	and    $0x1,%eax
8010014a:	85 c0                	test   %eax,%eax
8010014c:	75 38                	jne    80100186 <bget+0xd6>
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 04             	and    $0x4,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 2c                	jne    80100186 <bget+0xd6>
      b->dev = dev;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 08             	mov    0x8(%ebp),%edx
80100160:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	8b 55 0c             	mov    0xc(%ebp),%edx
80100169:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100175:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010017c:	e8 0c 4a 00 00       	call   80104b8d <release>
      return b;
80100181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100184:	eb 1e                	jmp    801001a4 <bget+0xf4>
      goto loop;
    }
  }

  // Not cached; recycle some non-busy and clean buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100189:	8b 40 0c             	mov    0xc(%eax),%eax
8010018c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010018f:	81 7d f4 a4 db 10 80 	cmpl   $0x8010dba4,-0xc(%ebp)
80100196:	75 aa                	jne    80100142 <bget+0x92>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100198:	c7 04 24 bf 81 10 80 	movl   $0x801081bf,(%esp)
8010019f:	e8 92 03 00 00       	call   80100536 <panic>
}
801001a4:	c9                   	leave  
801001a5:	c3                   	ret    

801001a6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001a6:	55                   	push   %ebp
801001a7:	89 e5                	mov    %esp,%ebp
801001a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, sector);
801001ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801001af:	89 44 24 04          	mov    %eax,0x4(%esp)
801001b3:	8b 45 08             	mov    0x8(%ebp),%eax
801001b6:	89 04 24             	mov    %eax,(%esp)
801001b9:	e8 f2 fe ff ff       	call   801000b0 <bget>
801001be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001c4:	8b 00                	mov    (%eax),%eax
801001c6:	83 e0 02             	and    $0x2,%eax
801001c9:	85 c0                	test   %eax,%eax
801001cb:	75 0b                	jne    801001d8 <bread+0x32>
    iderw(b);
801001cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d0:	89 04 24             	mov    %eax,(%esp)
801001d3:	e8 85 25 00 00       	call   8010275d <iderw>
  return b;
801001d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001db:	c9                   	leave  
801001dc:	c3                   	ret    

801001dd <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001dd:	55                   	push   %ebp
801001de:	89 e5                	mov    %esp,%ebp
801001e0:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
801001e3:	8b 45 08             	mov    0x8(%ebp),%eax
801001e6:	8b 00                	mov    (%eax),%eax
801001e8:	83 e0 01             	and    $0x1,%eax
801001eb:	85 c0                	test   %eax,%eax
801001ed:	75 0c                	jne    801001fb <bwrite+0x1e>
    panic("bwrite");
801001ef:	c7 04 24 d0 81 10 80 	movl   $0x801081d0,(%esp)
801001f6:	e8 3b 03 00 00       	call   80100536 <panic>
  b->flags |= B_DIRTY;
801001fb:	8b 45 08             	mov    0x8(%ebp),%eax
801001fe:	8b 00                	mov    (%eax),%eax
80100200:	89 c2                	mov    %eax,%edx
80100202:	83 ca 04             	or     $0x4,%edx
80100205:	8b 45 08             	mov    0x8(%ebp),%eax
80100208:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010020a:	8b 45 08             	mov    0x8(%ebp),%eax
8010020d:	89 04 24             	mov    %eax,(%esp)
80100210:	e8 48 25 00 00       	call   8010275d <iderw>
}
80100215:	c9                   	leave  
80100216:	c3                   	ret    

80100217 <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100217:	55                   	push   %ebp
80100218:	89 e5                	mov    %esp,%ebp
8010021a:	83 ec 18             	sub    $0x18,%esp
  if((b->flags & B_BUSY) == 0)
8010021d:	8b 45 08             	mov    0x8(%ebp),%eax
80100220:	8b 00                	mov    (%eax),%eax
80100222:	83 e0 01             	and    $0x1,%eax
80100225:	85 c0                	test   %eax,%eax
80100227:	75 0c                	jne    80100235 <brelse+0x1e>
    panic("brelse");
80100229:	c7 04 24 d7 81 10 80 	movl   $0x801081d7,(%esp)
80100230:	e8 01 03 00 00       	call   80100536 <panic>

  acquire(&bcache.lock);
80100235:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
8010023c:	e8 ea 48 00 00       	call   80104b2b <acquire>

  b->next->prev = b->prev;
80100241:	8b 45 08             	mov    0x8(%ebp),%eax
80100244:	8b 40 10             	mov    0x10(%eax),%eax
80100247:	8b 55 08             	mov    0x8(%ebp),%edx
8010024a:	8b 52 0c             	mov    0xc(%edx),%edx
8010024d:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	8b 40 0c             	mov    0xc(%eax),%eax
80100256:	8b 55 08             	mov    0x8(%ebp),%edx
80100259:	8b 52 10             	mov    0x10(%edx),%edx
8010025c:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010025f:	8b 15 b4 db 10 80    	mov    0x8010dbb4,%edx
80100265:	8b 45 08             	mov    0x8(%ebp),%eax
80100268:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010026b:	8b 45 08             	mov    0x8(%ebp),%eax
8010026e:	c7 40 0c a4 db 10 80 	movl   $0x8010dba4,0xc(%eax)
  bcache.head.next->prev = b;
80100275:	a1 b4 db 10 80       	mov    0x8010dbb4,%eax
8010027a:	8b 55 08             	mov    0x8(%ebp),%edx
8010027d:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
80100280:	8b 45 08             	mov    0x8(%ebp),%eax
80100283:	a3 b4 db 10 80       	mov    %eax,0x8010dbb4

  b->flags &= ~B_BUSY;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	8b 00                	mov    (%eax),%eax
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 fe             	and    $0xfffffffe,%edx
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80100297:	8b 45 08             	mov    0x8(%ebp),%eax
8010029a:	89 04 24             	mov    %eax,(%esp)
8010029d:	e8 3d 46 00 00       	call   801048df <wakeup>

  release(&bcache.lock);
801002a2:	c7 04 24 80 c6 10 80 	movl   $0x8010c680,(%esp)
801002a9:	e8 df 48 00 00       	call   80104b8d <release>
}
801002ae:	c9                   	leave  
801002af:	c3                   	ret    

801002b0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002b0:	55                   	push   %ebp
801002b1:	89 e5                	mov    %esp,%ebp
801002b3:	53                   	push   %ebx
801002b4:	83 ec 14             	sub    $0x14,%esp
801002b7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ba:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002be:	8b 55 e8             	mov    -0x18(%ebp),%edx
801002c1:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801002c5:	66 8b 55 ea          	mov    -0x16(%ebp),%dx
801002c9:	ec                   	in     (%dx),%al
801002ca:	88 c3                	mov    %al,%bl
801002cc:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801002cf:	8a 45 fb             	mov    -0x5(%ebp),%al
}
801002d2:	83 c4 14             	add    $0x14,%esp
801002d5:	5b                   	pop    %ebx
801002d6:	5d                   	pop    %ebp
801002d7:	c3                   	ret    

801002d8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 08             	sub    $0x8,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	8b 55 0c             	mov    0xc(%ebp),%edx
801002e4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801002e8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801002eb:	8a 45 f8             	mov    -0x8(%ebp),%al
801002ee:	8b 55 fc             	mov    -0x4(%ebp),%edx
801002f1:	ee                   	out    %al,(%dx)
}
801002f2:	c9                   	leave  
801002f3:	c3                   	ret    

801002f4 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801002f4:	55                   	push   %ebp
801002f5:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801002f7:	fa                   	cli    
}
801002f8:	5d                   	pop    %ebp
801002f9:	c3                   	ret    

801002fa <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
801002fa:	55                   	push   %ebp
801002fb:	89 e5                	mov    %esp,%ebp
801002fd:	83 ec 48             	sub    $0x48,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100300:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100304:	74 1c                	je     80100322 <printint+0x28>
80100306:	8b 45 08             	mov    0x8(%ebp),%eax
80100309:	c1 e8 1f             	shr    $0x1f,%eax
8010030c:	0f b6 c0             	movzbl %al,%eax
8010030f:	89 45 10             	mov    %eax,0x10(%ebp)
80100312:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100316:	74 0a                	je     80100322 <printint+0x28>
    x = -xx;
80100318:	8b 45 08             	mov    0x8(%ebp),%eax
8010031b:	f7 d8                	neg    %eax
8010031d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100320:	eb 06                	jmp    80100328 <printint+0x2e>
  else
    x = xx;
80100322:	8b 45 08             	mov    0x8(%ebp),%eax
80100325:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100328:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010032f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100332:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100335:	ba 00 00 00 00       	mov    $0x0,%edx
8010033a:	f7 f1                	div    %ecx
8010033c:	89 d0                	mov    %edx,%eax
8010033e:	8a 80 04 90 10 80    	mov    -0x7fef6ffc(%eax),%al
80100344:	8d 4d e0             	lea    -0x20(%ebp),%ecx
80100347:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010034a:	01 ca                	add    %ecx,%edx
8010034c:	88 02                	mov    %al,(%edx)
8010034e:	ff 45 f4             	incl   -0xc(%ebp)
  }while((x /= base) != 0);
80100351:	8b 55 0c             	mov    0xc(%ebp),%edx
80100354:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80100357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035a:	ba 00 00 00 00       	mov    $0x0,%edx
8010035f:	f7 75 d4             	divl   -0x2c(%ebp)
80100362:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100365:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100369:	75 c4                	jne    8010032f <printint+0x35>

  if(sign)
8010036b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010036f:	74 25                	je     80100396 <printint+0x9c>
    buf[i++] = '-';
80100371:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100374:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100377:	01 d0                	add    %edx,%eax
80100379:	c6 00 2d             	movb   $0x2d,(%eax)
8010037c:	ff 45 f4             	incl   -0xc(%ebp)

  while(--i >= 0)
8010037f:	eb 15                	jmp    80100396 <printint+0x9c>
    consputc(buf[i]);
80100381:	8d 55 e0             	lea    -0x20(%ebp),%edx
80100384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100387:	01 d0                	add    %edx,%eax
80100389:	8a 00                	mov    (%eax),%al
8010038b:	0f be c0             	movsbl %al,%eax
8010038e:	89 04 24             	mov    %eax,(%esp)
80100391:	e8 9d 03 00 00       	call   80100733 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
80100396:	ff 4d f4             	decl   -0xc(%ebp)
80100399:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010039d:	79 e2                	jns    80100381 <printint+0x87>
    consputc(buf[i]);
}
8010039f:	c9                   	leave  
801003a0:	c3                   	ret    

801003a1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003a1:	55                   	push   %ebp
801003a2:	89 e5                	mov    %esp,%ebp
801003a4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003a7:	a1 14 b6 10 80       	mov    0x8010b614,%eax
801003ac:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003af:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003b3:	74 0c                	je     801003c1 <cprintf+0x20>
    acquire(&cons.lock);
801003b5:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
801003bc:	e8 6a 47 00 00       	call   80104b2b <acquire>

  if (fmt == 0)
801003c1:	8b 45 08             	mov    0x8(%ebp),%eax
801003c4:	85 c0                	test   %eax,%eax
801003c6:	75 0c                	jne    801003d4 <cprintf+0x33>
    panic("null fmt");
801003c8:	c7 04 24 de 81 10 80 	movl   $0x801081de,(%esp)
801003cf:	e8 62 01 00 00       	call   80100536 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003d4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801003e1:	e9 1a 01 00 00       	jmp    80100500 <cprintf+0x15f>
    if(c != '%'){
801003e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801003ea:	74 10                	je     801003fc <cprintf+0x5b>
      consputc(c);
801003ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801003ef:	89 04 24             	mov    %eax,(%esp)
801003f2:	e8 3c 03 00 00       	call   80100733 <consputc>
      continue;
801003f7:	e9 01 01 00 00       	jmp    801004fd <cprintf+0x15c>
    }
    c = fmt[++i] & 0xff;
801003fc:	8b 55 08             	mov    0x8(%ebp),%edx
801003ff:	ff 45 f4             	incl   -0xc(%ebp)
80100402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100405:	01 d0                	add    %edx,%eax
80100407:	8a 00                	mov    (%eax),%al
80100409:	0f be c0             	movsbl %al,%eax
8010040c:	25 ff 00 00 00       	and    $0xff,%eax
80100411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100414:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100418:	0f 84 03 01 00 00    	je     80100521 <cprintf+0x180>
      break;
    switch(c){
8010041e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100421:	83 f8 70             	cmp    $0x70,%eax
80100424:	74 4d                	je     80100473 <cprintf+0xd2>
80100426:	83 f8 70             	cmp    $0x70,%eax
80100429:	7f 13                	jg     8010043e <cprintf+0x9d>
8010042b:	83 f8 25             	cmp    $0x25,%eax
8010042e:	0f 84 a3 00 00 00    	je     801004d7 <cprintf+0x136>
80100434:	83 f8 64             	cmp    $0x64,%eax
80100437:	74 14                	je     8010044d <cprintf+0xac>
80100439:	e9 a7 00 00 00       	jmp    801004e5 <cprintf+0x144>
8010043e:	83 f8 73             	cmp    $0x73,%eax
80100441:	74 53                	je     80100496 <cprintf+0xf5>
80100443:	83 f8 78             	cmp    $0x78,%eax
80100446:	74 2b                	je     80100473 <cprintf+0xd2>
80100448:	e9 98 00 00 00       	jmp    801004e5 <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010044d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100450:	8b 00                	mov    (%eax),%eax
80100452:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
80100456:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010045d:	00 
8010045e:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100465:	00 
80100466:	89 04 24             	mov    %eax,(%esp)
80100469:	e8 8c fe ff ff       	call   801002fa <printint>
      break;
8010046e:	e9 8a 00 00 00       	jmp    801004fd <cprintf+0x15c>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100473:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100476:	8b 00                	mov    (%eax),%eax
80100478:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
8010047c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100483:	00 
80100484:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
8010048b:	00 
8010048c:	89 04 24             	mov    %eax,(%esp)
8010048f:	e8 66 fe ff ff       	call   801002fa <printint>
      break;
80100494:	eb 67                	jmp    801004fd <cprintf+0x15c>
    case 's':
      if((s = (char*)*argp++) == 0)
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8b 00                	mov    (%eax),%eax
8010049b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010049e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004a2:	0f 94 c0             	sete   %al
801004a5:	83 45 f0 04          	addl   $0x4,-0x10(%ebp)
801004a9:	84 c0                	test   %al,%al
801004ab:	74 1e                	je     801004cb <cprintf+0x12a>
        s = "(null)";
801004ad:	c7 45 ec e7 81 10 80 	movl   $0x801081e7,-0x14(%ebp)
      for(; *s; s++)
801004b4:	eb 15                	jmp    801004cb <cprintf+0x12a>
        consputc(*s);
801004b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004b9:	8a 00                	mov    (%eax),%al
801004bb:	0f be c0             	movsbl %al,%eax
801004be:	89 04 24             	mov    %eax,(%esp)
801004c1:	e8 6d 02 00 00       	call   80100733 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004c6:	ff 45 ec             	incl   -0x14(%ebp)
801004c9:	eb 01                	jmp    801004cc <cprintf+0x12b>
801004cb:	90                   	nop
801004cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004cf:	8a 00                	mov    (%eax),%al
801004d1:	84 c0                	test   %al,%al
801004d3:	75 e1                	jne    801004b6 <cprintf+0x115>
        consputc(*s);
      break;
801004d5:	eb 26                	jmp    801004fd <cprintf+0x15c>
    case '%':
      consputc('%');
801004d7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004de:	e8 50 02 00 00       	call   80100733 <consputc>
      break;
801004e3:	eb 18                	jmp    801004fd <cprintf+0x15c>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801004e5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ec:	e8 42 02 00 00       	call   80100733 <consputc>
      consputc(c);
801004f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004f4:	89 04 24             	mov    %eax,(%esp)
801004f7:	e8 37 02 00 00       	call   80100733 <consputc>
      break;
801004fc:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801004fd:	ff 45 f4             	incl   -0xc(%ebp)
80100500:	8b 55 08             	mov    0x8(%ebp),%edx
80100503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100506:	01 d0                	add    %edx,%eax
80100508:	8a 00                	mov    (%eax),%al
8010050a:	0f be c0             	movsbl %al,%eax
8010050d:	25 ff 00 00 00       	and    $0xff,%eax
80100512:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100515:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100519:	0f 85 c7 fe ff ff    	jne    801003e6 <cprintf+0x45>
8010051f:	eb 01                	jmp    80100522 <cprintf+0x181>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
80100521:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
80100522:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100526:	74 0c                	je     80100534 <cprintf+0x193>
    release(&cons.lock);
80100528:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
8010052f:	e8 59 46 00 00       	call   80104b8d <release>
}
80100534:	c9                   	leave  
80100535:	c3                   	ret    

80100536 <panic>:

void
panic(char *s)
{
80100536:	55                   	push   %ebp
80100537:	89 e5                	mov    %esp,%ebp
80100539:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];
  
  cli();
8010053c:	e8 b3 fd ff ff       	call   801002f4 <cli>
  cons.locking = 0;
80100541:	c7 05 14 b6 10 80 00 	movl   $0x0,0x8010b614
80100548:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010054b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100551:	8a 00                	mov    (%eax),%al
80100553:	0f b6 c0             	movzbl %al,%eax
80100556:	89 44 24 04          	mov    %eax,0x4(%esp)
8010055a:	c7 04 24 ee 81 10 80 	movl   $0x801081ee,(%esp)
80100561:	e8 3b fe ff ff       	call   801003a1 <cprintf>
  cprintf(s);
80100566:	8b 45 08             	mov    0x8(%ebp),%eax
80100569:	89 04 24             	mov    %eax,(%esp)
8010056c:	e8 30 fe ff ff       	call   801003a1 <cprintf>
  cprintf("\n");
80100571:	c7 04 24 fd 81 10 80 	movl   $0x801081fd,(%esp)
80100578:	e8 24 fe ff ff       	call   801003a1 <cprintf>
  getcallerpcs(&s, pcs);
8010057d:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100580:	89 44 24 04          	mov    %eax,0x4(%esp)
80100584:	8d 45 08             	lea    0x8(%ebp),%eax
80100587:	89 04 24             	mov    %eax,(%esp)
8010058a:	e8 4d 46 00 00       	call   80104bdc <getcallerpcs>
  for(i=0; i<10; i++)
8010058f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100596:	eb 1a                	jmp    801005b2 <panic+0x7c>
    cprintf(" %p", pcs[i]);
80100598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010059b:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010059f:	89 44 24 04          	mov    %eax,0x4(%esp)
801005a3:	c7 04 24 ff 81 10 80 	movl   $0x801081ff,(%esp)
801005aa:	e8 f2 fd ff ff       	call   801003a1 <cprintf>
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005af:	ff 45 f4             	incl   -0xc(%ebp)
801005b2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005b6:	7e e0                	jle    80100598 <panic+0x62>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005b8:	c7 05 c0 b5 10 80 01 	movl   $0x1,0x8010b5c0
801005bf:	00 00 00 
  for(;;)
    ;
801005c2:	eb fe                	jmp    801005c2 <panic+0x8c>

801005c4 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005c4:	55                   	push   %ebp
801005c5:	89 e5                	mov    %esp,%ebp
801005c7:	83 ec 28             	sub    $0x28,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005ca:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005d1:	00 
801005d2:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005d9:	e8 fa fc ff ff       	call   801002d8 <outb>
  pos = inb(CRTPORT+1) << 8;
801005de:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005e5:	e8 c6 fc ff ff       	call   801002b0 <inb>
801005ea:	0f b6 c0             	movzbl %al,%eax
801005ed:	c1 e0 08             	shl    $0x8,%eax
801005f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
801005f3:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801005fa:	00 
801005fb:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100602:	e8 d1 fc ff ff       	call   801002d8 <outb>
  pos |= inb(CRTPORT+1);
80100607:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010060e:	e8 9d fc ff ff       	call   801002b0 <inb>
80100613:	0f b6 c0             	movzbl %al,%eax
80100616:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100619:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010061d:	75 1d                	jne    8010063c <cgaputc+0x78>
    pos += 80 - pos%80;
8010061f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100622:	b9 50 00 00 00       	mov    $0x50,%ecx
80100627:	99                   	cltd   
80100628:	f7 f9                	idiv   %ecx
8010062a:	89 d0                	mov    %edx,%eax
8010062c:	ba 50 00 00 00       	mov    $0x50,%edx
80100631:	89 d1                	mov    %edx,%ecx
80100633:	29 c1                	sub    %eax,%ecx
80100635:	89 c8                	mov    %ecx,%eax
80100637:	01 45 f4             	add    %eax,-0xc(%ebp)
8010063a:	eb 31                	jmp    8010066d <cgaputc+0xa9>
  else if(c == BACKSPACE){
8010063c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100643:	75 0b                	jne    80100650 <cgaputc+0x8c>
    if(pos > 0) --pos;
80100645:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100649:	7e 22                	jle    8010066d <cgaputc+0xa9>
8010064b:	ff 4d f4             	decl   -0xc(%ebp)
8010064e:	eb 1d                	jmp    8010066d <cgaputc+0xa9>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100650:	a1 00 90 10 80       	mov    0x80109000,%eax
80100655:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100658:	d1 e2                	shl    %edx
8010065a:	01 c2                	add    %eax,%edx
8010065c:	8b 45 08             	mov    0x8(%ebp),%eax
8010065f:	25 ff 00 00 00       	and    $0xff,%eax
80100664:	80 cc 07             	or     $0x7,%ah
80100667:	66 89 02             	mov    %ax,(%edx)
8010066a:	ff 45 f4             	incl   -0xc(%ebp)
  
  if((pos/80) >= 24){  // Scroll up.
8010066d:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100674:	7e 53                	jle    801006c9 <cgaputc+0x105>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100676:	a1 00 90 10 80       	mov    0x80109000,%eax
8010067b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100681:	a1 00 90 10 80       	mov    0x80109000,%eax
80100686:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
8010068d:	00 
8010068e:	89 54 24 04          	mov    %edx,0x4(%esp)
80100692:	89 04 24             	mov    %eax,(%esp)
80100695:	e8 b0 47 00 00       	call   80104e4a <memmove>
    pos -= 80;
8010069a:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8010069e:	b8 80 07 00 00       	mov    $0x780,%eax
801006a3:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006a6:	d1 e0                	shl    %eax
801006a8:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801006ae:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006b1:	d1 e1                	shl    %ecx
801006b3:	01 ca                	add    %ecx,%edx
801006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
801006b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006c0:	00 
801006c1:	89 14 24             	mov    %edx,(%esp)
801006c4:	e8 b5 46 00 00       	call   80104d7e <memset>
  }
  
  outb(CRTPORT, 14);
801006c9:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801006d0:	00 
801006d1:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801006d8:	e8 fb fb ff ff       	call   801002d8 <outb>
  outb(CRTPORT+1, pos>>8);
801006dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006e0:	c1 f8 08             	sar    $0x8,%eax
801006e3:	0f b6 c0             	movzbl %al,%eax
801006e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801006ea:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801006f1:	e8 e2 fb ff ff       	call   801002d8 <outb>
  outb(CRTPORT, 15);
801006f6:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801006fd:	00 
801006fe:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100705:	e8 ce fb ff ff       	call   801002d8 <outb>
  outb(CRTPORT+1, pos);
8010070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010070d:	0f b6 c0             	movzbl %al,%eax
80100710:	89 44 24 04          	mov    %eax,0x4(%esp)
80100714:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010071b:	e8 b8 fb ff ff       	call   801002d8 <outb>
  crt[pos] = ' ' | 0x0700;
80100720:	a1 00 90 10 80       	mov    0x80109000,%eax
80100725:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100728:	d1 e2                	shl    %edx
8010072a:	01 d0                	add    %edx,%eax
8010072c:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100731:	c9                   	leave  
80100732:	c3                   	ret    

80100733 <consputc>:

void
consputc(int c)
{
80100733:	55                   	push   %ebp
80100734:	89 e5                	mov    %esp,%ebp
80100736:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
80100739:	a1 c0 b5 10 80       	mov    0x8010b5c0,%eax
8010073e:	85 c0                	test   %eax,%eax
80100740:	74 07                	je     80100749 <consputc+0x16>
    cli();
80100742:	e8 ad fb ff ff       	call   801002f4 <cli>
    for(;;)
      ;
80100747:	eb fe                	jmp    80100747 <consputc+0x14>
  }

  if(c == BACKSPACE){
80100749:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100750:	75 26                	jne    80100778 <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100752:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100759:	e8 cc 60 00 00       	call   8010682a <uartputc>
8010075e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100765:	e8 c0 60 00 00       	call   8010682a <uartputc>
8010076a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100771:	e8 b4 60 00 00       	call   8010682a <uartputc>
80100776:	eb 0b                	jmp    80100783 <consputc+0x50>
  } else
    uartputc(c);
80100778:	8b 45 08             	mov    0x8(%ebp),%eax
8010077b:	89 04 24             	mov    %eax,(%esp)
8010077e:	e8 a7 60 00 00       	call   8010682a <uartputc>
  cgaputc(c);
80100783:	8b 45 08             	mov    0x8(%ebp),%eax
80100786:	89 04 24             	mov    %eax,(%esp)
80100789:	e8 36 fe ff ff       	call   801005c4 <cgaputc>
}
8010078e:	c9                   	leave  
8010078f:	c3                   	ret    

80100790 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100790:	55                   	push   %ebp
80100791:	89 e5                	mov    %esp,%ebp
80100793:	83 ec 28             	sub    $0x28,%esp
  int c;

  acquire(&input.lock);
80100796:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
8010079d:	e8 89 43 00 00       	call   80104b2b <acquire>
  while((c = getc()) >= 0){
801007a2:	e9 35 01 00 00       	jmp    801008dc <consoleintr+0x14c>
    switch(c){
801007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007aa:	83 f8 10             	cmp    $0x10,%eax
801007ad:	74 1b                	je     801007ca <consoleintr+0x3a>
801007af:	83 f8 10             	cmp    $0x10,%eax
801007b2:	7f 0a                	jg     801007be <consoleintr+0x2e>
801007b4:	83 f8 08             	cmp    $0x8,%eax
801007b7:	74 60                	je     80100819 <consoleintr+0x89>
801007b9:	e9 8a 00 00 00       	jmp    80100848 <consoleintr+0xb8>
801007be:	83 f8 15             	cmp    $0x15,%eax
801007c1:	74 2a                	je     801007ed <consoleintr+0x5d>
801007c3:	83 f8 7f             	cmp    $0x7f,%eax
801007c6:	74 51                	je     80100819 <consoleintr+0x89>
801007c8:	eb 7e                	jmp    80100848 <consoleintr+0xb8>
    case C('P'):  // Process listing.
      procdump();
801007ca:	e8 b6 41 00 00       	call   80104985 <procdump>
      break;
801007cf:	e9 08 01 00 00       	jmp    801008dc <consoleintr+0x14c>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801007d4:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801007d9:	48                   	dec    %eax
801007da:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
801007df:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801007e6:	e8 48 ff ff ff       	call   80100733 <consputc>
801007eb:	eb 01                	jmp    801007ee <consoleintr+0x5e>
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801007ed:	90                   	nop
801007ee:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
801007f4:	a1 78 de 10 80       	mov    0x8010de78,%eax
801007f9:	39 c2                	cmp    %eax,%edx
801007fb:	0f 84 d4 00 00 00    	je     801008d5 <consoleintr+0x145>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100801:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100806:	48                   	dec    %eax
80100807:	83 e0 7f             	and    $0x7f,%eax
8010080a:	8a 80 f4 dd 10 80    	mov    -0x7fef220c(%eax),%al
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100810:	3c 0a                	cmp    $0xa,%al
80100812:	75 c0                	jne    801007d4 <consoleintr+0x44>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100814:	e9 bc 00 00 00       	jmp    801008d5 <consoleintr+0x145>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100819:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
8010081f:	a1 78 de 10 80       	mov    0x8010de78,%eax
80100824:	39 c2                	cmp    %eax,%edx
80100826:	0f 84 ac 00 00 00    	je     801008d8 <consoleintr+0x148>
        input.e--;
8010082c:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100831:	48                   	dec    %eax
80100832:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(BACKSPACE);
80100837:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010083e:	e8 f0 fe ff ff       	call   80100733 <consputc>
      }
      break;
80100843:	e9 90 00 00 00       	jmp    801008d8 <consoleintr+0x148>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100848:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010084c:	0f 84 89 00 00 00    	je     801008db <consoleintr+0x14b>
80100852:	8b 15 7c de 10 80    	mov    0x8010de7c,%edx
80100858:	a1 74 de 10 80       	mov    0x8010de74,%eax
8010085d:	89 d1                	mov    %edx,%ecx
8010085f:	29 c1                	sub    %eax,%ecx
80100861:	89 c8                	mov    %ecx,%eax
80100863:	83 f8 7f             	cmp    $0x7f,%eax
80100866:	77 73                	ja     801008db <consoleintr+0x14b>
        c = (c == '\r') ? '\n' : c;
80100868:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
8010086c:	74 05                	je     80100873 <consoleintr+0xe3>
8010086e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100871:	eb 05                	jmp    80100878 <consoleintr+0xe8>
80100873:	b8 0a 00 00 00       	mov    $0xa,%eax
80100878:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010087b:	a1 7c de 10 80       	mov    0x8010de7c,%eax
80100880:	89 c1                	mov    %eax,%ecx
80100882:	83 e1 7f             	and    $0x7f,%ecx
80100885:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100888:	88 91 f4 dd 10 80    	mov    %dl,-0x7fef220c(%ecx)
8010088e:	40                   	inc    %eax
8010088f:	a3 7c de 10 80       	mov    %eax,0x8010de7c
        consputc(c);
80100894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100897:	89 04 24             	mov    %eax,(%esp)
8010089a:	e8 94 fe ff ff       	call   80100733 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010089f:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
801008a3:	74 18                	je     801008bd <consoleintr+0x12d>
801008a5:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
801008a9:	74 12                	je     801008bd <consoleintr+0x12d>
801008ab:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008b0:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
801008b6:	83 ea 80             	sub    $0xffffff80,%edx
801008b9:	39 d0                	cmp    %edx,%eax
801008bb:	75 1e                	jne    801008db <consoleintr+0x14b>
          input.w = input.e;
801008bd:	a1 7c de 10 80       	mov    0x8010de7c,%eax
801008c2:	a3 78 de 10 80       	mov    %eax,0x8010de78
          wakeup(&input.r);
801008c7:	c7 04 24 74 de 10 80 	movl   $0x8010de74,(%esp)
801008ce:	e8 0c 40 00 00       	call   801048df <wakeup>
        }
      }
      break;
801008d3:	eb 06                	jmp    801008db <consoleintr+0x14b>
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008d5:	90                   	nop
801008d6:	eb 04                	jmp    801008dc <consoleintr+0x14c>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008d8:	90                   	nop
801008d9:	eb 01                	jmp    801008dc <consoleintr+0x14c>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
          input.w = input.e;
          wakeup(&input.r);
        }
      }
      break;
801008db:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
801008dc:	8b 45 08             	mov    0x8(%ebp),%eax
801008df:	ff d0                	call   *%eax
801008e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801008e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008e8:	0f 89 b9 fe ff ff    	jns    801007a7 <consoleintr+0x17>
        }
      }
      break;
    }
  }
  release(&input.lock);
801008ee:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
801008f5:	e8 93 42 00 00       	call   80104b8d <release>
}
801008fa:	c9                   	leave  
801008fb:	c3                   	ret    

801008fc <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801008fc:	55                   	push   %ebp
801008fd:	89 e5                	mov    %esp,%ebp
801008ff:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100902:	8b 45 08             	mov    0x8(%ebp),%eax
80100905:	89 04 24             	mov    %eax,(%esp)
80100908:	e8 60 10 00 00       	call   8010196d <iunlock>
  target = n;
8010090d:	8b 45 10             	mov    0x10(%ebp),%eax
80100910:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100913:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
8010091a:	e8 0c 42 00 00       	call   80104b2b <acquire>
  while(n > 0){
8010091f:	e9 a1 00 00 00       	jmp    801009c5 <consoleread+0xc9>
    while(input.r == input.w){
      if(proc->killed){
80100924:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010092a:	8b 40 24             	mov    0x24(%eax),%eax
8010092d:	85 c0                	test   %eax,%eax
8010092f:	74 21                	je     80100952 <consoleread+0x56>
        release(&input.lock);
80100931:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100938:	e8 50 42 00 00       	call   80104b8d <release>
        ilock(ip);
8010093d:	8b 45 08             	mov    0x8(%ebp),%eax
80100940:	89 04 24             	mov    %eax,(%esp)
80100943:	e8 da 0e 00 00       	call   80101822 <ilock>
        return -1;
80100948:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010094d:	e9 a2 00 00 00       	jmp    801009f4 <consoleread+0xf8>
      }
      sleep(&input.r, &input.lock);
80100952:	c7 44 24 04 c0 dd 10 	movl   $0x8010ddc0,0x4(%esp)
80100959:	80 
8010095a:	c7 04 24 74 de 10 80 	movl   $0x8010de74,(%esp)
80100961:	e8 9d 3e 00 00       	call   80104803 <sleep>
80100966:	eb 01                	jmp    80100969 <consoleread+0x6d>

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
80100968:	90                   	nop
80100969:	8b 15 74 de 10 80    	mov    0x8010de74,%edx
8010096f:	a1 78 de 10 80       	mov    0x8010de78,%eax
80100974:	39 c2                	cmp    %eax,%edx
80100976:	74 ac                	je     80100924 <consoleread+0x28>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100978:	a1 74 de 10 80       	mov    0x8010de74,%eax
8010097d:	89 c2                	mov    %eax,%edx
8010097f:	83 e2 7f             	and    $0x7f,%edx
80100982:	8a 92 f4 dd 10 80    	mov    -0x7fef220c(%edx),%dl
80100988:	0f be d2             	movsbl %dl,%edx
8010098b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010098e:	40                   	inc    %eax
8010098f:	a3 74 de 10 80       	mov    %eax,0x8010de74
    if(c == C('D')){  // EOF
80100994:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100998:	75 15                	jne    801009af <consoleread+0xb3>
      if(n < target){
8010099a:	8b 45 10             	mov    0x10(%ebp),%eax
8010099d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801009a0:	73 2b                	jae    801009cd <consoleread+0xd1>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801009a2:	a1 74 de 10 80       	mov    0x8010de74,%eax
801009a7:	48                   	dec    %eax
801009a8:	a3 74 de 10 80       	mov    %eax,0x8010de74
      }
      break;
801009ad:	eb 1e                	jmp    801009cd <consoleread+0xd1>
    }
    *dst++ = c;
801009af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801009b2:	88 c2                	mov    %al,%dl
801009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801009b7:	88 10                	mov    %dl,(%eax)
801009b9:	ff 45 0c             	incl   0xc(%ebp)
    --n;
801009bc:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
801009bf:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
801009c3:	74 0b                	je     801009d0 <consoleread+0xd4>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
801009c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801009c9:	7f 9d                	jg     80100968 <consoleread+0x6c>
801009cb:	eb 04                	jmp    801009d1 <consoleread+0xd5>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
801009cd:	90                   	nop
801009ce:	eb 01                	jmp    801009d1 <consoleread+0xd5>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
801009d0:	90                   	nop
  }
  release(&input.lock);
801009d1:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
801009d8:	e8 b0 41 00 00       	call   80104b8d <release>
  ilock(ip);
801009dd:	8b 45 08             	mov    0x8(%ebp),%eax
801009e0:	89 04 24             	mov    %eax,(%esp)
801009e3:	e8 3a 0e 00 00       	call   80101822 <ilock>

  return target - n;
801009e8:	8b 45 10             	mov    0x10(%ebp),%eax
801009eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801009ee:	89 d1                	mov    %edx,%ecx
801009f0:	29 c1                	sub    %eax,%ecx
801009f2:	89 c8                	mov    %ecx,%eax
}
801009f4:	c9                   	leave  
801009f5:	c3                   	ret    

801009f6 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801009f6:	55                   	push   %ebp
801009f7:	89 e5                	mov    %esp,%ebp
801009f9:	83 ec 28             	sub    $0x28,%esp
  int i;

  iunlock(ip);
801009fc:	8b 45 08             	mov    0x8(%ebp),%eax
801009ff:	89 04 24             	mov    %eax,(%esp)
80100a02:	e8 66 0f 00 00       	call   8010196d <iunlock>
  acquire(&cons.lock);
80100a07:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a0e:	e8 18 41 00 00       	call   80104b2b <acquire>
  for(i = 0; i < n; i++)
80100a13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a1a:	eb 1d                	jmp    80100a39 <consolewrite+0x43>
    consputc(buf[i] & 0xff);
80100a1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a22:	01 d0                	add    %edx,%eax
80100a24:	8a 00                	mov    (%eax),%al
80100a26:	0f be c0             	movsbl %al,%eax
80100a29:	25 ff 00 00 00       	and    $0xff,%eax
80100a2e:	89 04 24             	mov    %eax,(%esp)
80100a31:	e8 fd fc ff ff       	call   80100733 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100a36:	ff 45 f4             	incl   -0xc(%ebp)
80100a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100a3c:	3b 45 10             	cmp    0x10(%ebp),%eax
80100a3f:	7c db                	jl     80100a1c <consolewrite+0x26>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100a41:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a48:	e8 40 41 00 00       	call   80104b8d <release>
  ilock(ip);
80100a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80100a50:	89 04 24             	mov    %eax,(%esp)
80100a53:	e8 ca 0d 00 00       	call   80101822 <ilock>

  return n;
80100a58:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100a5b:	c9                   	leave  
80100a5c:	c3                   	ret    

80100a5d <consoleinit>:

void
consoleinit(void)
{
80100a5d:	55                   	push   %ebp
80100a5e:	89 e5                	mov    %esp,%ebp
80100a60:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100a63:	c7 44 24 04 03 82 10 	movl   $0x80108203,0x4(%esp)
80100a6a:	80 
80100a6b:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100a72:	e8 93 40 00 00       	call   80104b0a <initlock>
  initlock(&input.lock, "input");
80100a77:	c7 44 24 04 0b 82 10 	movl   $0x8010820b,0x4(%esp)
80100a7e:	80 
80100a7f:	c7 04 24 c0 dd 10 80 	movl   $0x8010ddc0,(%esp)
80100a86:	e8 7f 40 00 00       	call   80104b0a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100a8b:	c7 05 2c e8 10 80 f6 	movl   $0x801009f6,0x8010e82c
80100a92:	09 10 80 
  devsw[CONSOLE].read = consoleread;
80100a95:	c7 05 28 e8 10 80 fc 	movl   $0x801008fc,0x8010e828
80100a9c:	08 10 80 
  cons.locking = 1;
80100a9f:	c7 05 14 b6 10 80 01 	movl   $0x1,0x8010b614
80100aa6:	00 00 00 

  picenable(IRQ_KBD);
80100aa9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ab0:	e8 cf 2f 00 00       	call   80103a84 <picenable>
  ioapicenable(IRQ_KBD, 0);
80100ab5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100abc:	00 
80100abd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100ac4:	e8 50 1e 00 00       	call   80102919 <ioapicenable>
}
80100ac9:	c9                   	leave  
80100aca:	c3                   	ret    
80100acb:	90                   	nop

80100acc <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100acc:	55                   	push   %ebp
80100acd:	89 e5                	mov    %esp,%ebp
80100acf:	81 ec 38 01 00 00    	sub    $0x138,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  if((ip = namei(path)) == 0)
80100ad5:	8b 45 08             	mov    0x8(%ebp),%eax
80100ad8:	89 04 24             	mov    %eax,(%esp)
80100adb:	e8 dc 18 00 00       	call   801023bc <namei>
80100ae0:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100ae3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ae7:	75 0a                	jne    80100af3 <exec+0x27>
    return -1;
80100ae9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100aee:	e9 e3 03 00 00       	jmp    80100ed6 <exec+0x40a>
  ilock(ip);
80100af3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100af6:	89 04 24             	mov    %eax,(%esp)
80100af9:	e8 24 0d 00 00       	call   80101822 <ilock>
  pgdir = 0;
80100afe:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b05:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100b0c:	00 
80100b0d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100b14:	00 
80100b15:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b1f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b22:	89 04 24             	mov    %eax,(%esp)
80100b25:	e8 ff 11 00 00       	call   80101d29 <readi>
80100b2a:	83 f8 33             	cmp    $0x33,%eax
80100b2d:	0f 86 5d 03 00 00    	jbe    80100e90 <exec+0x3c4>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b33:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100b39:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100b3e:	0f 85 4f 03 00 00    	jne    80100e93 <exec+0x3c7>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b44:	e8 07 6e 00 00       	call   80107950 <setupkvm>
80100b49:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100b4c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100b50:	0f 84 40 03 00 00    	je     80100e96 <exec+0x3ca>
    goto bad;

  // Load program into memory.
  sz = 0;
80100b56:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b5d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100b64:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100b6a:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100b6d:	e9 c4 00 00 00       	jmp    80100c36 <exec+0x16a>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100b72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100b75:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100b7c:	00 
80100b7d:	89 44 24 08          	mov    %eax,0x8(%esp)
80100b81:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100b87:	89 44 24 04          	mov    %eax,0x4(%esp)
80100b8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100b8e:	89 04 24             	mov    %eax,(%esp)
80100b91:	e8 93 11 00 00       	call   80101d29 <readi>
80100b96:	83 f8 20             	cmp    $0x20,%eax
80100b99:	0f 85 fa 02 00 00    	jne    80100e99 <exec+0x3cd>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100b9f:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ba5:	83 f8 01             	cmp    $0x1,%eax
80100ba8:	75 7f                	jne    80100c29 <exec+0x15d>
      continue;
    if(ph.memsz < ph.filesz)
80100baa:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100bb0:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100bb6:	39 c2                	cmp    %eax,%edx
80100bb8:	0f 82 de 02 00 00    	jb     80100e9c <exec+0x3d0>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100bbe:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100bc4:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100bca:	01 d0                	add    %edx,%eax
80100bcc:	89 44 24 08          	mov    %eax,0x8(%esp)
80100bd0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100bd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100bd7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100bda:	89 04 24             	mov    %eax,(%esp)
80100bdd:	e8 34 71 00 00       	call   80107d16 <allocuvm>
80100be2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100be5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100be9:	0f 84 b0 02 00 00    	je     80100e9f <exec+0x3d3>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100bef:	8b 8d fc fe ff ff    	mov    -0x104(%ebp),%ecx
80100bf5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100bfb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100c01:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100c05:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100c09:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100c0c:	89 54 24 08          	mov    %edx,0x8(%esp)
80100c10:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c17:	89 04 24             	mov    %eax,(%esp)
80100c1a:	e8 08 70 00 00       	call   80107c27 <loaduvm>
80100c1f:	85 c0                	test   %eax,%eax
80100c21:	0f 88 7b 02 00 00    	js     80100ea2 <exec+0x3d6>
80100c27:	eb 01                	jmp    80100c2a <exec+0x15e>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c29:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c2a:	ff 45 ec             	incl   -0x14(%ebp)
80100c2d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c30:	83 c0 20             	add    $0x20,%eax
80100c33:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c36:	8b 85 38 ff ff ff    	mov    -0xc8(%ebp),%eax
80100c3c:	0f b7 c0             	movzwl %ax,%eax
80100c3f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100c42:	0f 8f 2a ff ff ff    	jg     80100b72 <exec+0xa6>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100c48:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c4b:	89 04 24             	mov    %eax,(%esp)
80100c4e:	e8 50 0e 00 00       	call   80101aa3 <iunlockput>
  ip = 0;
80100c53:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100c5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c5d:	05 ff 0f 00 00       	add    $0xfff,%eax
80100c62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100c67:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c6a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c6d:	05 00 20 00 00       	add    $0x2000,%eax
80100c72:	89 44 24 08          	mov    %eax,0x8(%esp)
80100c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c79:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c7d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100c80:	89 04 24             	mov    %eax,(%esp)
80100c83:	e8 8e 70 00 00       	call   80107d16 <allocuvm>
80100c88:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c8b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c8f:	0f 84 10 02 00 00    	je     80100ea5 <exec+0x3d9>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100c98:	2d 00 20 00 00       	sub    $0x2000,%eax
80100c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ca1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ca4:	89 04 24             	mov    %eax,(%esp)
80100ca7:	e8 99 72 00 00       	call   80107f45 <clearpteu>
  sp = sz;
80100cac:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100caf:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100cb2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100cb9:	e9 94 00 00 00       	jmp    80100d52 <exec+0x286>
    if(argc >= MAXARG)
80100cbe:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100cc2:	0f 87 e0 01 00 00    	ja     80100ea8 <exec+0x3dc>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ccb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cd5:	01 d0                	add    %edx,%eax
80100cd7:	8b 00                	mov    (%eax),%eax
80100cd9:	89 04 24             	mov    %eax,(%esp)
80100cdc:	e8 f8 42 00 00       	call   80104fd9 <strlen>
80100ce1:	f7 d0                	not    %eax
80100ce3:	89 c2                	mov    %eax,%edx
80100ce5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ce8:	01 d0                	add    %edx,%eax
80100cea:	83 e0 fc             	and    $0xfffffffc,%eax
80100ced:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100cf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100cf3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cfd:	01 d0                	add    %edx,%eax
80100cff:	8b 00                	mov    (%eax),%eax
80100d01:	89 04 24             	mov    %eax,(%esp)
80100d04:	e8 d0 42 00 00       	call   80104fd9 <strlen>
80100d09:	40                   	inc    %eax
80100d0a:	89 c2                	mov    %eax,%edx
80100d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d0f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100d16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d19:	01 c8                	add    %ecx,%eax
80100d1b:	8b 00                	mov    (%eax),%eax
80100d1d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d21:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d25:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d28:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d2f:	89 04 24             	mov    %eax,(%esp)
80100d32:	e8 d3 73 00 00       	call   8010810a <copyout>
80100d37:	85 c0                	test   %eax,%eax
80100d39:	0f 88 6c 01 00 00    	js     80100eab <exec+0x3df>
      goto bad;
    ustack[3+argc] = sp;
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	8d 50 03             	lea    0x3(%eax),%edx
80100d45:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d48:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d4f:	ff 45 e4             	incl   -0x1c(%ebp)
80100d52:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d55:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5f:	01 d0                	add    %edx,%eax
80100d61:	8b 00                	mov    (%eax),%eax
80100d63:	85 c0                	test   %eax,%eax
80100d65:	0f 85 53 ff ff ff    	jne    80100cbe <exec+0x1f2>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6e:	83 c0 03             	add    $0x3,%eax
80100d71:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100d78:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100d7c:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100d83:	ff ff ff 
  ustack[1] = argc;
80100d86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d89:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d92:	40                   	inc    %eax
80100d93:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d9d:	29 d0                	sub    %edx,%eax
80100d9f:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100da5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100da8:	83 c0 04             	add    $0x4,%eax
80100dab:	c1 e0 02             	shl    $0x2,%eax
80100dae:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100db1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db4:	83 c0 04             	add    $0x4,%eax
80100db7:	c1 e0 02             	shl    $0x2,%eax
80100dba:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100dbe:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100dc4:	89 44 24 08          	mov    %eax,0x8(%esp)
80100dc8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80100dcf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dd2:	89 04 24             	mov    %eax,(%esp)
80100dd5:	e8 30 73 00 00       	call   8010810a <copyout>
80100dda:	85 c0                	test   %eax,%eax
80100ddc:	0f 88 cc 00 00 00    	js     80100eae <exec+0x3e2>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100de2:	8b 45 08             	mov    0x8(%ebp),%eax
80100de5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100deb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100dee:	eb 13                	jmp    80100e03 <exec+0x337>
    if(*s == '/')
80100df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100df3:	8a 00                	mov    (%eax),%al
80100df5:	3c 2f                	cmp    $0x2f,%al
80100df7:	75 07                	jne    80100e00 <exec+0x334>
      last = s+1;
80100df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100dfc:	40                   	inc    %eax
80100dfd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e00:	ff 45 f4             	incl   -0xc(%ebp)
80100e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e06:	8a 00                	mov    (%eax),%al
80100e08:	84 c0                	test   %al,%al
80100e0a:	75 e4                	jne    80100df0 <exec+0x324>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e0c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e12:	8d 50 6c             	lea    0x6c(%eax),%edx
80100e15:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100e1c:	00 
80100e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100e20:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e24:	89 14 24             	mov    %edx,(%esp)
80100e27:	e8 64 41 00 00       	call   80104f90 <safestrcpy>

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e32:	8b 40 04             	mov    0x4(%eax),%eax
80100e35:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100e38:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e3e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100e41:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100e44:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e4a:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100e4d:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100e4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e55:	8b 40 18             	mov    0x18(%eax),%eax
80100e58:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100e5e:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100e61:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e67:	8b 40 18             	mov    0x18(%eax),%eax
80100e6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e6d:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100e70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e76:	89 04 24             	mov    %eax,(%esp)
80100e79:	e8 c3 6b 00 00       	call   80107a41 <switchuvm>
  freevm(oldpgdir);
80100e7e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100e81:	89 04 24             	mov    %eax,(%esp)
80100e84:	e8 23 70 00 00       	call   80107eac <freevm>
  return 0;
80100e89:	b8 00 00 00 00       	mov    $0x0,%eax
80100e8e:	eb 46                	jmp    80100ed6 <exec+0x40a>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100e90:	90                   	nop
80100e91:	eb 1c                	jmp    80100eaf <exec+0x3e3>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100e93:	90                   	nop
80100e94:	eb 19                	jmp    80100eaf <exec+0x3e3>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100e96:	90                   	nop
80100e97:	eb 16                	jmp    80100eaf <exec+0x3e3>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100e99:	90                   	nop
80100e9a:	eb 13                	jmp    80100eaf <exec+0x3e3>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100e9c:	90                   	nop
80100e9d:	eb 10                	jmp    80100eaf <exec+0x3e3>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100e9f:	90                   	nop
80100ea0:	eb 0d                	jmp    80100eaf <exec+0x3e3>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100ea2:	90                   	nop
80100ea3:	eb 0a                	jmp    80100eaf <exec+0x3e3>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100ea5:	90                   	nop
80100ea6:	eb 07                	jmp    80100eaf <exec+0x3e3>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100ea8:	90                   	nop
80100ea9:	eb 04                	jmp    80100eaf <exec+0x3e3>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100eab:	90                   	nop
80100eac:	eb 01                	jmp    80100eaf <exec+0x3e3>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100eae:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100eaf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100eb3:	74 0b                	je     80100ec0 <exec+0x3f4>
    freevm(pgdir);
80100eb5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100eb8:	89 04 24             	mov    %eax,(%esp)
80100ebb:	e8 ec 6f 00 00       	call   80107eac <freevm>
  if(ip)
80100ec0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100ec4:	74 0b                	je     80100ed1 <exec+0x405>
    iunlockput(ip);
80100ec6:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ec9:	89 04 24             	mov    %eax,(%esp)
80100ecc:	e8 d2 0b 00 00       	call   80101aa3 <iunlockput>
  return -1;
80100ed1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100ed6:	c9                   	leave  
80100ed7:	c3                   	ret    

80100ed8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100ed8:	55                   	push   %ebp
80100ed9:	89 e5                	mov    %esp,%ebp
80100edb:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100ede:	c7 44 24 04 11 82 10 	movl   $0x80108211,0x4(%esp)
80100ee5:	80 
80100ee6:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100eed:	e8 18 3c 00 00       	call   80104b0a <initlock>
}
80100ef2:	c9                   	leave  
80100ef3:	c3                   	ret    

80100ef4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100ef4:	55                   	push   %ebp
80100ef5:	89 e5                	mov    %esp,%ebp
80100ef7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80100efa:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f01:	e8 25 3c 00 00       	call   80104b2b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f06:	c7 45 f4 b4 de 10 80 	movl   $0x8010deb4,-0xc(%ebp)
80100f0d:	eb 29                	jmp    80100f38 <filealloc+0x44>
    if(f->ref == 0){
80100f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f12:	8b 40 04             	mov    0x4(%eax),%eax
80100f15:	85 c0                	test   %eax,%eax
80100f17:	75 1b                	jne    80100f34 <filealloc+0x40>
      f->ref = 1;
80100f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f1c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100f23:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f2a:	e8 5e 3c 00 00       	call   80104b8d <release>
      return f;
80100f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f32:	eb 1e                	jmp    80100f52 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f34:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100f38:	81 7d f4 14 e8 10 80 	cmpl   $0x8010e814,-0xc(%ebp)
80100f3f:	72 ce                	jb     80100f0f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100f41:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f48:	e8 40 3c 00 00       	call   80104b8d <release>
  return 0;
80100f4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100f52:	c9                   	leave  
80100f53:	c3                   	ret    

80100f54 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f54:	55                   	push   %ebp
80100f55:	89 e5                	mov    %esp,%ebp
80100f57:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80100f5a:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f61:	e8 c5 3b 00 00       	call   80104b2b <acquire>
  if(f->ref < 1)
80100f66:	8b 45 08             	mov    0x8(%ebp),%eax
80100f69:	8b 40 04             	mov    0x4(%eax),%eax
80100f6c:	85 c0                	test   %eax,%eax
80100f6e:	7f 0c                	jg     80100f7c <filedup+0x28>
    panic("filedup");
80100f70:	c7 04 24 18 82 10 80 	movl   $0x80108218,(%esp)
80100f77:	e8 ba f5 ff ff       	call   80100536 <panic>
  f->ref++;
80100f7c:	8b 45 08             	mov    0x8(%ebp),%eax
80100f7f:	8b 40 04             	mov    0x4(%eax),%eax
80100f82:	8d 50 01             	lea    0x1(%eax),%edx
80100f85:	8b 45 08             	mov    0x8(%ebp),%eax
80100f88:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80100f8b:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100f92:	e8 f6 3b 00 00       	call   80104b8d <release>
  return f;
80100f97:	8b 45 08             	mov    0x8(%ebp),%eax
}
80100f9a:	c9                   	leave  
80100f9b:	c3                   	ret    

80100f9c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100f9c:	55                   	push   %ebp
80100f9d:	89 e5                	mov    %esp,%ebp
80100f9f:	57                   	push   %edi
80100fa0:	56                   	push   %esi
80100fa1:	53                   	push   %ebx
80100fa2:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
80100fa5:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100fac:	e8 7a 3b 00 00       	call   80104b2b <acquire>
  if(f->ref < 1)
80100fb1:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb4:	8b 40 04             	mov    0x4(%eax),%eax
80100fb7:	85 c0                	test   %eax,%eax
80100fb9:	7f 0c                	jg     80100fc7 <fileclose+0x2b>
    panic("fileclose");
80100fbb:	c7 04 24 20 82 10 80 	movl   $0x80108220,(%esp)
80100fc2:	e8 6f f5 ff ff       	call   80100536 <panic>
  if(--f->ref > 0){
80100fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80100fca:	8b 40 04             	mov    0x4(%eax),%eax
80100fcd:	8d 50 ff             	lea    -0x1(%eax),%edx
80100fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd3:	89 50 04             	mov    %edx,0x4(%eax)
80100fd6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fd9:	8b 40 04             	mov    0x4(%eax),%eax
80100fdc:	85 c0                	test   %eax,%eax
80100fde:	7e 0e                	jle    80100fee <fileclose+0x52>
    release(&ftable.lock);
80100fe0:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
80100fe7:	e8 a1 3b 00 00       	call   80104b8d <release>
80100fec:	eb 70                	jmp    8010105e <fileclose+0xc2>
    return;
  }
  ff = *f;
80100fee:	8b 45 08             	mov    0x8(%ebp),%eax
80100ff1:	8d 55 d0             	lea    -0x30(%ebp),%edx
80100ff4:	89 c3                	mov    %eax,%ebx
80100ff6:	b8 06 00 00 00       	mov    $0x6,%eax
80100ffb:	89 d7                	mov    %edx,%edi
80100ffd:	89 de                	mov    %ebx,%esi
80100fff:	89 c1                	mov    %eax,%ecx
80101001:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80101003:	8b 45 08             	mov    0x8(%ebp),%eax
80101006:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010100d:	8b 45 08             	mov    0x8(%ebp),%eax
80101010:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101016:	c7 04 24 80 de 10 80 	movl   $0x8010de80,(%esp)
8010101d:	e8 6b 3b 00 00       	call   80104b8d <release>
  
  if(ff.type == FD_PIPE)
80101022:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101025:	83 f8 01             	cmp    $0x1,%eax
80101028:	75 17                	jne    80101041 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
8010102a:	8a 45 d9             	mov    -0x27(%ebp),%al
8010102d:	0f be d0             	movsbl %al,%edx
80101030:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101033:	89 54 24 04          	mov    %edx,0x4(%esp)
80101037:	89 04 24             	mov    %eax,(%esp)
8010103a:	e8 fc 2c 00 00       	call   80103d3b <pipeclose>
8010103f:	eb 1d                	jmp    8010105e <fileclose+0xc2>
  else if(ff.type == FD_INODE){
80101041:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101044:	83 f8 02             	cmp    $0x2,%eax
80101047:	75 15                	jne    8010105e <fileclose+0xc2>
    begin_trans();
80101049:	e8 61 21 00 00       	call   801031af <begin_trans>
    iput(ff.ip);
8010104e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101051:	89 04 24             	mov    %eax,(%esp)
80101054:	e8 79 09 00 00       	call   801019d2 <iput>
    commit_trans();
80101059:	e8 9a 21 00 00       	call   801031f8 <commit_trans>
  }
}
8010105e:	83 c4 3c             	add    $0x3c,%esp
80101061:	5b                   	pop    %ebx
80101062:	5e                   	pop    %esi
80101063:	5f                   	pop    %edi
80101064:	5d                   	pop    %ebp
80101065:	c3                   	ret    

80101066 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101066:	55                   	push   %ebp
80101067:	89 e5                	mov    %esp,%ebp
80101069:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010106c:	8b 45 08             	mov    0x8(%ebp),%eax
8010106f:	8b 00                	mov    (%eax),%eax
80101071:	83 f8 02             	cmp    $0x2,%eax
80101074:	75 38                	jne    801010ae <filestat+0x48>
    ilock(f->ip);
80101076:	8b 45 08             	mov    0x8(%ebp),%eax
80101079:	8b 40 10             	mov    0x10(%eax),%eax
8010107c:	89 04 24             	mov    %eax,(%esp)
8010107f:	e8 9e 07 00 00       	call   80101822 <ilock>
    stati(f->ip, st);
80101084:	8b 45 08             	mov    0x8(%ebp),%eax
80101087:	8b 40 10             	mov    0x10(%eax),%eax
8010108a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010108d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101091:	89 04 24             	mov    %eax,(%esp)
80101094:	e8 4c 0c 00 00       	call   80101ce5 <stati>
    iunlock(f->ip);
80101099:	8b 45 08             	mov    0x8(%ebp),%eax
8010109c:	8b 40 10             	mov    0x10(%eax),%eax
8010109f:	89 04 24             	mov    %eax,(%esp)
801010a2:	e8 c6 08 00 00       	call   8010196d <iunlock>
    return 0;
801010a7:	b8 00 00 00 00       	mov    $0x0,%eax
801010ac:	eb 05                	jmp    801010b3 <filestat+0x4d>
  }
  return -1;
801010ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010b3:	c9                   	leave  
801010b4:	c3                   	ret    

801010b5 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010b5:	55                   	push   %ebp
801010b6:	89 e5                	mov    %esp,%ebp
801010b8:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8a 40 08             	mov    0x8(%eax),%al
801010c1:	84 c0                	test   %al,%al
801010c3:	75 0a                	jne    801010cf <fileread+0x1a>
    return -1;
801010c5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801010ca:	e9 9f 00 00 00       	jmp    8010116e <fileread+0xb9>
  if(f->type == FD_PIPE)
801010cf:	8b 45 08             	mov    0x8(%ebp),%eax
801010d2:	8b 00                	mov    (%eax),%eax
801010d4:	83 f8 01             	cmp    $0x1,%eax
801010d7:	75 1e                	jne    801010f7 <fileread+0x42>
    return piperead(f->pipe, addr, n);
801010d9:	8b 45 08             	mov    0x8(%ebp),%eax
801010dc:	8b 40 0c             	mov    0xc(%eax),%eax
801010df:	8b 55 10             	mov    0x10(%ebp),%edx
801010e2:	89 54 24 08          	mov    %edx,0x8(%esp)
801010e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801010e9:	89 54 24 04          	mov    %edx,0x4(%esp)
801010ed:	89 04 24             	mov    %eax,(%esp)
801010f0:	e8 c8 2d 00 00       	call   80103ebd <piperead>
801010f5:	eb 77                	jmp    8010116e <fileread+0xb9>
  if(f->type == FD_INODE){
801010f7:	8b 45 08             	mov    0x8(%ebp),%eax
801010fa:	8b 00                	mov    (%eax),%eax
801010fc:	83 f8 02             	cmp    $0x2,%eax
801010ff:	75 61                	jne    80101162 <fileread+0xad>
    ilock(f->ip);
80101101:	8b 45 08             	mov    0x8(%ebp),%eax
80101104:	8b 40 10             	mov    0x10(%eax),%eax
80101107:	89 04 24             	mov    %eax,(%esp)
8010110a:	e8 13 07 00 00       	call   80101822 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010110f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101112:	8b 45 08             	mov    0x8(%ebp),%eax
80101115:	8b 50 14             	mov    0x14(%eax),%edx
80101118:	8b 45 08             	mov    0x8(%ebp),%eax
8010111b:	8b 40 10             	mov    0x10(%eax),%eax
8010111e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101122:	89 54 24 08          	mov    %edx,0x8(%esp)
80101126:	8b 55 0c             	mov    0xc(%ebp),%edx
80101129:	89 54 24 04          	mov    %edx,0x4(%esp)
8010112d:	89 04 24             	mov    %eax,(%esp)
80101130:	e8 f4 0b 00 00       	call   80101d29 <readi>
80101135:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101138:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010113c:	7e 11                	jle    8010114f <fileread+0x9a>
      f->off += r;
8010113e:	8b 45 08             	mov    0x8(%ebp),%eax
80101141:	8b 50 14             	mov    0x14(%eax),%edx
80101144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101147:	01 c2                	add    %eax,%edx
80101149:	8b 45 08             	mov    0x8(%ebp),%eax
8010114c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010114f:	8b 45 08             	mov    0x8(%ebp),%eax
80101152:	8b 40 10             	mov    0x10(%eax),%eax
80101155:	89 04 24             	mov    %eax,(%esp)
80101158:	e8 10 08 00 00       	call   8010196d <iunlock>
    return r;
8010115d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101160:	eb 0c                	jmp    8010116e <fileread+0xb9>
  }
  panic("fileread");
80101162:	c7 04 24 2a 82 10 80 	movl   $0x8010822a,(%esp)
80101169:	e8 c8 f3 ff ff       	call   80100536 <panic>
}
8010116e:	c9                   	leave  
8010116f:	c3                   	ret    

80101170 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101170:	55                   	push   %ebp
80101171:	89 e5                	mov    %esp,%ebp
80101173:	53                   	push   %ebx
80101174:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
80101177:	8b 45 08             	mov    0x8(%ebp),%eax
8010117a:	8a 40 09             	mov    0x9(%eax),%al
8010117d:	84 c0                	test   %al,%al
8010117f:	75 0a                	jne    8010118b <filewrite+0x1b>
    return -1;
80101181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101186:	e9 23 01 00 00       	jmp    801012ae <filewrite+0x13e>
  if(f->type == FD_PIPE)
8010118b:	8b 45 08             	mov    0x8(%ebp),%eax
8010118e:	8b 00                	mov    (%eax),%eax
80101190:	83 f8 01             	cmp    $0x1,%eax
80101193:	75 21                	jne    801011b6 <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
80101195:	8b 45 08             	mov    0x8(%ebp),%eax
80101198:	8b 40 0c             	mov    0xc(%eax),%eax
8010119b:	8b 55 10             	mov    0x10(%ebp),%edx
8010119e:	89 54 24 08          	mov    %edx,0x8(%esp)
801011a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801011a5:	89 54 24 04          	mov    %edx,0x4(%esp)
801011a9:	89 04 24             	mov    %eax,(%esp)
801011ac:	e8 1c 2c 00 00       	call   80103dcd <pipewrite>
801011b1:	e9 f8 00 00 00       	jmp    801012ae <filewrite+0x13e>
  if(f->type == FD_INODE){
801011b6:	8b 45 08             	mov    0x8(%ebp),%eax
801011b9:	8b 00                	mov    (%eax),%eax
801011bb:	83 f8 02             	cmp    $0x2,%eax
801011be:	0f 85 de 00 00 00    	jne    801012a2 <filewrite+0x132>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801011c4:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801011cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801011d2:	e9 a8 00 00 00       	jmp    8010127f <filewrite+0x10f>
      int n1 = n - i;
801011d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011da:	8b 55 10             	mov    0x10(%ebp),%edx
801011dd:	89 d1                	mov    %edx,%ecx
801011df:	29 c1                	sub    %eax,%ecx
801011e1:	89 c8                	mov    %ecx,%eax
801011e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801011ec:	7e 06                	jle    801011f4 <filewrite+0x84>
        n1 = max;
801011ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_trans();
801011f4:	e8 b6 1f 00 00       	call   801031af <begin_trans>
      ilock(f->ip);
801011f9:	8b 45 08             	mov    0x8(%ebp),%eax
801011fc:	8b 40 10             	mov    0x10(%eax),%eax
801011ff:	89 04 24             	mov    %eax,(%esp)
80101202:	e8 1b 06 00 00       	call   80101822 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101207:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010120a:	8b 45 08             	mov    0x8(%ebp),%eax
8010120d:	8b 50 14             	mov    0x14(%eax),%edx
80101210:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101213:	8b 45 0c             	mov    0xc(%ebp),%eax
80101216:	01 c3                	add    %eax,%ebx
80101218:	8b 45 08             	mov    0x8(%ebp),%eax
8010121b:	8b 40 10             	mov    0x10(%eax),%eax
8010121e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101222:	89 54 24 08          	mov    %edx,0x8(%esp)
80101226:	89 5c 24 04          	mov    %ebx,0x4(%esp)
8010122a:	89 04 24             	mov    %eax,(%esp)
8010122d:	e8 5c 0c 00 00       	call   80101e8e <writei>
80101232:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101235:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101239:	7e 11                	jle    8010124c <filewrite+0xdc>
        f->off += r;
8010123b:	8b 45 08             	mov    0x8(%ebp),%eax
8010123e:	8b 50 14             	mov    0x14(%eax),%edx
80101241:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101244:	01 c2                	add    %eax,%edx
80101246:	8b 45 08             	mov    0x8(%ebp),%eax
80101249:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010124c:	8b 45 08             	mov    0x8(%ebp),%eax
8010124f:	8b 40 10             	mov    0x10(%eax),%eax
80101252:	89 04 24             	mov    %eax,(%esp)
80101255:	e8 13 07 00 00       	call   8010196d <iunlock>
      commit_trans();
8010125a:	e8 99 1f 00 00       	call   801031f8 <commit_trans>

      if(r < 0)
8010125f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101263:	78 28                	js     8010128d <filewrite+0x11d>
        break;
      if(r != n1)
80101265:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101268:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010126b:	74 0c                	je     80101279 <filewrite+0x109>
        panic("short filewrite");
8010126d:	c7 04 24 33 82 10 80 	movl   $0x80108233,(%esp)
80101274:	e8 bd f2 ff ff       	call   80100536 <panic>
      i += r;
80101279:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010127c:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010127f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101282:	3b 45 10             	cmp    0x10(%ebp),%eax
80101285:	0f 8c 4c ff ff ff    	jl     801011d7 <filewrite+0x67>
8010128b:	eb 01                	jmp    8010128e <filewrite+0x11e>
        f->off += r;
      iunlock(f->ip);
      commit_trans();

      if(r < 0)
        break;
8010128d:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010128e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101291:	3b 45 10             	cmp    0x10(%ebp),%eax
80101294:	75 05                	jne    8010129b <filewrite+0x12b>
80101296:	8b 45 10             	mov    0x10(%ebp),%eax
80101299:	eb 05                	jmp    801012a0 <filewrite+0x130>
8010129b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012a0:	eb 0c                	jmp    801012ae <filewrite+0x13e>
  }
  panic("filewrite");
801012a2:	c7 04 24 43 82 10 80 	movl   $0x80108243,(%esp)
801012a9:	e8 88 f2 ff ff       	call   80100536 <panic>
}
801012ae:	83 c4 24             	add    $0x24,%esp
801012b1:	5b                   	pop    %ebx
801012b2:	5d                   	pop    %ebp
801012b3:	c3                   	ret    

801012b4 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801012b4:	55                   	push   %ebp
801012b5:	89 e5                	mov    %esp,%ebp
801012b7:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801012ba:	8b 45 08             	mov    0x8(%ebp),%eax
801012bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801012c4:	00 
801012c5:	89 04 24             	mov    %eax,(%esp)
801012c8:	e8 d9 ee ff ff       	call   801001a6 <bread>
801012cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801012d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d3:	83 c0 18             	add    $0x18,%eax
801012d6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801012dd:	00 
801012de:	89 44 24 04          	mov    %eax,0x4(%esp)
801012e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801012e5:	89 04 24             	mov    %eax,(%esp)
801012e8:	e8 5d 3b 00 00       	call   80104e4a <memmove>
  brelse(bp);
801012ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012f0:	89 04 24             	mov    %eax,(%esp)
801012f3:	e8 1f ef ff ff       	call   80100217 <brelse>
}
801012f8:	c9                   	leave  
801012f9:	c3                   	ret    

801012fa <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801012fa:	55                   	push   %ebp
801012fb:	89 e5                	mov    %esp,%ebp
801012fd:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101300:	8b 55 0c             	mov    0xc(%ebp),%edx
80101303:	8b 45 08             	mov    0x8(%ebp),%eax
80101306:	89 54 24 04          	mov    %edx,0x4(%esp)
8010130a:	89 04 24             	mov    %eax,(%esp)
8010130d:	e8 94 ee ff ff       	call   801001a6 <bread>
80101312:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101318:	83 c0 18             	add    $0x18,%eax
8010131b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101322:	00 
80101323:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010132a:	00 
8010132b:	89 04 24             	mov    %eax,(%esp)
8010132e:	e8 4b 3a 00 00       	call   80104d7e <memset>
  log_write(bp);
80101333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101336:	89 04 24             	mov    %eax,(%esp)
80101339:	e8 12 1f 00 00       	call   80103250 <log_write>
  brelse(bp);
8010133e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101341:	89 04 24             	mov    %eax,(%esp)
80101344:	e8 ce ee ff ff       	call   80100217 <brelse>
}
80101349:	c9                   	leave  
8010134a:	c3                   	ret    

8010134b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010134b:	55                   	push   %ebp
8010134c:	89 e5                	mov    %esp,%ebp
8010134e:	53                   	push   %ebx
8010134f:	83 ec 34             	sub    $0x34,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101352:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
80101359:	8b 45 08             	mov    0x8(%ebp),%eax
8010135c:	8d 55 d8             	lea    -0x28(%ebp),%edx
8010135f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101363:	89 04 24             	mov    %eax,(%esp)
80101366:	e8 49 ff ff ff       	call   801012b4 <readsb>
  for(b = 0; b < sb.size; b += BPB){
8010136b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101372:	e9 05 01 00 00       	jmp    8010147c <balloc+0x131>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
80101377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137a:	85 c0                	test   %eax,%eax
8010137c:	79 05                	jns    80101383 <balloc+0x38>
8010137e:	05 ff 0f 00 00       	add    $0xfff,%eax
80101383:	c1 f8 0c             	sar    $0xc,%eax
80101386:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101389:	c1 ea 03             	shr    $0x3,%edx
8010138c:	01 d0                	add    %edx,%eax
8010138e:	83 c0 03             	add    $0x3,%eax
80101391:	89 44 24 04          	mov    %eax,0x4(%esp)
80101395:	8b 45 08             	mov    0x8(%ebp),%eax
80101398:	89 04 24             	mov    %eax,(%esp)
8010139b:	e8 06 ee ff ff       	call   801001a6 <bread>
801013a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801013a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801013aa:	e9 9d 00 00 00       	jmp    8010144c <balloc+0x101>
      m = 1 << (bi % 8);
801013af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013b2:	25 07 00 00 80       	and    $0x80000007,%eax
801013b7:	85 c0                	test   %eax,%eax
801013b9:	79 05                	jns    801013c0 <balloc+0x75>
801013bb:	48                   	dec    %eax
801013bc:	83 c8 f8             	or     $0xfffffff8,%eax
801013bf:	40                   	inc    %eax
801013c0:	ba 01 00 00 00       	mov    $0x1,%edx
801013c5:	89 d3                	mov    %edx,%ebx
801013c7:	88 c1                	mov    %al,%cl
801013c9:	d3 e3                	shl    %cl,%ebx
801013cb:	89 d8                	mov    %ebx,%eax
801013cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801013d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013d3:	85 c0                	test   %eax,%eax
801013d5:	79 03                	jns    801013da <balloc+0x8f>
801013d7:	83 c0 07             	add    $0x7,%eax
801013da:	c1 f8 03             	sar    $0x3,%eax
801013dd:	8b 55 ec             	mov    -0x14(%ebp),%edx
801013e0:	8a 44 02 18          	mov    0x18(%edx,%eax,1),%al
801013e4:	0f b6 c0             	movzbl %al,%eax
801013e7:	23 45 e8             	and    -0x18(%ebp),%eax
801013ea:	85 c0                	test   %eax,%eax
801013ec:	75 5b                	jne    80101449 <balloc+0xfe>
        bp->data[bi/8] |= m;  // Mark block in use.
801013ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f1:	85 c0                	test   %eax,%eax
801013f3:	79 03                	jns    801013f8 <balloc+0xad>
801013f5:	83 c0 07             	add    $0x7,%eax
801013f8:	c1 f8 03             	sar    $0x3,%eax
801013fb:	8b 55 ec             	mov    -0x14(%ebp),%edx
801013fe:	8a 54 02 18          	mov    0x18(%edx,%eax,1),%dl
80101402:	88 d1                	mov    %dl,%cl
80101404:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101407:	09 ca                	or     %ecx,%edx
80101409:	88 d1                	mov    %dl,%cl
8010140b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010140e:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101412:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101415:	89 04 24             	mov    %eax,(%esp)
80101418:	e8 33 1e 00 00       	call   80103250 <log_write>
        brelse(bp);
8010141d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101420:	89 04 24             	mov    %eax,(%esp)
80101423:	e8 ef ed ff ff       	call   80100217 <brelse>
        bzero(dev, b + bi);
80101428:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010142b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010142e:	01 c2                	add    %eax,%edx
80101430:	8b 45 08             	mov    0x8(%ebp),%eax
80101433:	89 54 24 04          	mov    %edx,0x4(%esp)
80101437:	89 04 24             	mov    %eax,(%esp)
8010143a:	e8 bb fe ff ff       	call   801012fa <bzero>
        return b + bi;
8010143f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101442:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101445:	01 d0                	add    %edx,%eax
80101447:	eb 4d                	jmp    80101496 <balloc+0x14b>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101449:	ff 45 f0             	incl   -0x10(%ebp)
8010144c:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101453:	7f 15                	jg     8010146a <balloc+0x11f>
80101455:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101458:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010145b:	01 d0                	add    %edx,%eax
8010145d:	89 c2                	mov    %eax,%edx
8010145f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101462:	39 c2                	cmp    %eax,%edx
80101464:	0f 82 45 ff ff ff    	jb     801013af <balloc+0x64>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010146a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010146d:	89 04 24             	mov    %eax,(%esp)
80101470:	e8 a2 ed ff ff       	call   80100217 <brelse>
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101475:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010147c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010147f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101482:	39 c2                	cmp    %eax,%edx
80101484:	0f 82 ed fe ff ff    	jb     80101377 <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010148a:	c7 04 24 4d 82 10 80 	movl   $0x8010824d,(%esp)
80101491:	e8 a0 f0 ff ff       	call   80100536 <panic>
}
80101496:	83 c4 34             	add    $0x34,%esp
80101499:	5b                   	pop    %ebx
8010149a:	5d                   	pop    %ebp
8010149b:	c3                   	ret    

8010149c <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010149c:	55                   	push   %ebp
8010149d:	89 e5                	mov    %esp,%ebp
8010149f:	53                   	push   %ebx
801014a0:	83 ec 34             	sub    $0x34,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
801014a3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801014aa:	8b 45 08             	mov    0x8(%ebp),%eax
801014ad:	89 04 24             	mov    %eax,(%esp)
801014b0:	e8 ff fd ff ff       	call   801012b4 <readsb>
  bp = bread(dev, BBLOCK(b, sb.ninodes));
801014b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801014b8:	89 c2                	mov    %eax,%edx
801014ba:	c1 ea 0c             	shr    $0xc,%edx
801014bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801014c0:	c1 e8 03             	shr    $0x3,%eax
801014c3:	01 d0                	add    %edx,%eax
801014c5:	8d 50 03             	lea    0x3(%eax),%edx
801014c8:	8b 45 08             	mov    0x8(%ebp),%eax
801014cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801014cf:	89 04 24             	mov    %eax,(%esp)
801014d2:	e8 cf ec ff ff       	call   801001a6 <bread>
801014d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801014da:	8b 45 0c             	mov    0xc(%ebp),%eax
801014dd:	25 ff 0f 00 00       	and    $0xfff,%eax
801014e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801014e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014e8:	25 07 00 00 80       	and    $0x80000007,%eax
801014ed:	85 c0                	test   %eax,%eax
801014ef:	79 05                	jns    801014f6 <bfree+0x5a>
801014f1:	48                   	dec    %eax
801014f2:	83 c8 f8             	or     $0xfffffff8,%eax
801014f5:	40                   	inc    %eax
801014f6:	ba 01 00 00 00       	mov    $0x1,%edx
801014fb:	89 d3                	mov    %edx,%ebx
801014fd:	88 c1                	mov    %al,%cl
801014ff:	d3 e3                	shl    %cl,%ebx
80101501:	89 d8                	mov    %ebx,%eax
80101503:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101509:	85 c0                	test   %eax,%eax
8010150b:	79 03                	jns    80101510 <bfree+0x74>
8010150d:	83 c0 07             	add    $0x7,%eax
80101510:	c1 f8 03             	sar    $0x3,%eax
80101513:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101516:	8a 44 02 18          	mov    0x18(%edx,%eax,1),%al
8010151a:	0f b6 c0             	movzbl %al,%eax
8010151d:	23 45 ec             	and    -0x14(%ebp),%eax
80101520:	85 c0                	test   %eax,%eax
80101522:	75 0c                	jne    80101530 <bfree+0x94>
    panic("freeing free block");
80101524:	c7 04 24 63 82 10 80 	movl   $0x80108263,(%esp)
8010152b:	e8 06 f0 ff ff       	call   80100536 <panic>
  bp->data[bi/8] &= ~m;
80101530:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101533:	85 c0                	test   %eax,%eax
80101535:	79 03                	jns    8010153a <bfree+0x9e>
80101537:	83 c0 07             	add    $0x7,%eax
8010153a:	c1 f8 03             	sar    $0x3,%eax
8010153d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101540:	8a 54 02 18          	mov    0x18(%edx,%eax,1),%dl
80101544:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101547:	f7 d1                	not    %ecx
80101549:	21 ca                	and    %ecx,%edx
8010154b:	88 d1                	mov    %dl,%cl
8010154d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101550:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101557:	89 04 24             	mov    %eax,(%esp)
8010155a:	e8 f1 1c 00 00       	call   80103250 <log_write>
  brelse(bp);
8010155f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101562:	89 04 24             	mov    %eax,(%esp)
80101565:	e8 ad ec ff ff       	call   80100217 <brelse>
}
8010156a:	83 c4 34             	add    $0x34,%esp
8010156d:	5b                   	pop    %ebx
8010156e:	5d                   	pop    %ebp
8010156f:	c3                   	ret    

80101570 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101570:	55                   	push   %ebp
80101571:	89 e5                	mov    %esp,%ebp
80101573:	83 ec 18             	sub    $0x18,%esp
  initlock(&icache.lock, "icache");
80101576:	c7 44 24 04 76 82 10 	movl   $0x80108276,0x4(%esp)
8010157d:	80 
8010157e:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101585:	e8 80 35 00 00       	call   80104b0a <initlock>
}
8010158a:	c9                   	leave  
8010158b:	c3                   	ret    

8010158c <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010158c:	55                   	push   %ebp
8010158d:	89 e5                	mov    %esp,%ebp
8010158f:	83 ec 48             	sub    $0x48,%esp
80101592:	8b 45 0c             	mov    0xc(%ebp),%eax
80101595:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101599:	8b 45 08             	mov    0x8(%ebp),%eax
8010159c:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010159f:	89 54 24 04          	mov    %edx,0x4(%esp)
801015a3:	89 04 24             	mov    %eax,(%esp)
801015a6:	e8 09 fd ff ff       	call   801012b4 <readsb>

  for(inum = 1; inum < sb.ninodes; inum++){
801015ab:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801015b2:	e9 95 00 00 00       	jmp    8010164c <ialloc+0xc0>
    bp = bread(dev, IBLOCK(inum));
801015b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015ba:	c1 e8 03             	shr    $0x3,%eax
801015bd:	83 c0 02             	add    $0x2,%eax
801015c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801015c4:	8b 45 08             	mov    0x8(%ebp),%eax
801015c7:	89 04 24             	mov    %eax,(%esp)
801015ca:	e8 d7 eb ff ff       	call   801001a6 <bread>
801015cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801015d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d5:	8d 50 18             	lea    0x18(%eax),%edx
801015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015db:	83 e0 07             	and    $0x7,%eax
801015de:	c1 e0 06             	shl    $0x6,%eax
801015e1:	01 d0                	add    %edx,%eax
801015e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801015e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015e9:	8b 00                	mov    (%eax),%eax
801015eb:	66 85 c0             	test   %ax,%ax
801015ee:	75 4e                	jne    8010163e <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801015f0:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801015f7:	00 
801015f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801015ff:	00 
80101600:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101603:	89 04 24             	mov    %eax,(%esp)
80101606:	e8 73 37 00 00       	call   80104d7e <memset>
      dip->type = type;
8010160b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010160e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101611:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101614:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101617:	89 04 24             	mov    %eax,(%esp)
8010161a:	e8 31 1c 00 00       	call   80103250 <log_write>
      brelse(bp);
8010161f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101622:	89 04 24             	mov    %eax,(%esp)
80101625:	e8 ed eb ff ff       	call   80100217 <brelse>
      return iget(dev, inum);
8010162a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010162d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101631:	8b 45 08             	mov    0x8(%ebp),%eax
80101634:	89 04 24             	mov    %eax,(%esp)
80101637:	e8 e2 00 00 00       	call   8010171e <iget>
8010163c:	eb 28                	jmp    80101666 <ialloc+0xda>
    }
    brelse(bp);
8010163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101641:	89 04 24             	mov    %eax,(%esp)
80101644:	e8 ce eb ff ff       	call   80100217 <brelse>
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101649:	ff 45 f4             	incl   -0xc(%ebp)
8010164c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101652:	39 c2                	cmp    %eax,%edx
80101654:	0f 82 5d ff ff ff    	jb     801015b7 <ialloc+0x2b>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
8010165a:	c7 04 24 7d 82 10 80 	movl   $0x8010827d,(%esp)
80101661:	e8 d0 ee ff ff       	call   80100536 <panic>
}
80101666:	c9                   	leave  
80101667:	c3                   	ret    

80101668 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101668:	55                   	push   %ebp
80101669:	89 e5                	mov    %esp,%ebp
8010166b:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010166e:	8b 45 08             	mov    0x8(%ebp),%eax
80101671:	8b 40 04             	mov    0x4(%eax),%eax
80101674:	c1 e8 03             	shr    $0x3,%eax
80101677:	8d 50 02             	lea    0x2(%eax),%edx
8010167a:	8b 45 08             	mov    0x8(%ebp),%eax
8010167d:	8b 00                	mov    (%eax),%eax
8010167f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101683:	89 04 24             	mov    %eax,(%esp)
80101686:	e8 1b eb ff ff       	call   801001a6 <bread>
8010168b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010168e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101691:	8d 50 18             	lea    0x18(%eax),%edx
80101694:	8b 45 08             	mov    0x8(%ebp),%eax
80101697:	8b 40 04             	mov    0x4(%eax),%eax
8010169a:	83 e0 07             	and    $0x7,%eax
8010169d:	c1 e0 06             	shl    $0x6,%eax
801016a0:	01 d0                	add    %edx,%eax
801016a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801016a5:	8b 45 08             	mov    0x8(%ebp),%eax
801016a8:	8b 40 10             	mov    0x10(%eax),%eax
801016ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
801016ae:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801016b1:	8b 45 08             	mov    0x8(%ebp),%eax
801016b4:	66 8b 40 12          	mov    0x12(%eax),%ax
801016b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801016bb:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801016bf:	8b 45 08             	mov    0x8(%ebp),%eax
801016c2:	8b 40 14             	mov    0x14(%eax),%eax
801016c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801016c8:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801016cc:	8b 45 08             	mov    0x8(%ebp),%eax
801016cf:	66 8b 40 16          	mov    0x16(%eax),%ax
801016d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801016d6:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801016da:	8b 45 08             	mov    0x8(%ebp),%eax
801016dd:	8b 50 18             	mov    0x18(%eax),%edx
801016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016e3:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016e6:	8b 45 08             	mov    0x8(%ebp),%eax
801016e9:	8d 50 1c             	lea    0x1c(%eax),%edx
801016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ef:	83 c0 0c             	add    $0xc,%eax
801016f2:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801016f9:	00 
801016fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801016fe:	89 04 24             	mov    %eax,(%esp)
80101701:	e8 44 37 00 00       	call   80104e4a <memmove>
  log_write(bp);
80101706:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101709:	89 04 24             	mov    %eax,(%esp)
8010170c:	e8 3f 1b 00 00       	call   80103250 <log_write>
  brelse(bp);
80101711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101714:	89 04 24             	mov    %eax,(%esp)
80101717:	e8 fb ea ff ff       	call   80100217 <brelse>
}
8010171c:	c9                   	leave  
8010171d:	c3                   	ret    

8010171e <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010171e:	55                   	push   %ebp
8010171f:	89 e5                	mov    %esp,%ebp
80101721:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101724:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010172b:	e8 fb 33 00 00       	call   80104b2b <acquire>

  // Is the inode already cached?
  empty = 0;
80101730:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101737:	c7 45 f4 b4 e8 10 80 	movl   $0x8010e8b4,-0xc(%ebp)
8010173e:	eb 59                	jmp    80101799 <iget+0x7b>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101743:	8b 40 08             	mov    0x8(%eax),%eax
80101746:	85 c0                	test   %eax,%eax
80101748:	7e 35                	jle    8010177f <iget+0x61>
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	8b 00                	mov    (%eax),%eax
8010174f:	3b 45 08             	cmp    0x8(%ebp),%eax
80101752:	75 2b                	jne    8010177f <iget+0x61>
80101754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101757:	8b 40 04             	mov    0x4(%eax),%eax
8010175a:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010175d:	75 20                	jne    8010177f <iget+0x61>
      ip->ref++;
8010175f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101762:	8b 40 08             	mov    0x8(%eax),%eax
80101765:	8d 50 01             	lea    0x1(%eax),%edx
80101768:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176b:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010176e:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101775:	e8 13 34 00 00       	call   80104b8d <release>
      return ip;
8010177a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010177d:	eb 6f                	jmp    801017ee <iget+0xd0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010177f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101783:	75 10                	jne    80101795 <iget+0x77>
80101785:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101788:	8b 40 08             	mov    0x8(%eax),%eax
8010178b:	85 c0                	test   %eax,%eax
8010178d:	75 06                	jne    80101795 <iget+0x77>
      empty = ip;
8010178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101792:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101795:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101799:	81 7d f4 54 f8 10 80 	cmpl   $0x8010f854,-0xc(%ebp)
801017a0:	72 9e                	jb     80101740 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801017a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801017a6:	75 0c                	jne    801017b4 <iget+0x96>
    panic("iget: no inodes");
801017a8:	c7 04 24 8f 82 10 80 	movl   $0x8010828f,(%esp)
801017af:	e8 82 ed ff ff       	call   80100536 <panic>

  ip = empty;
801017b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801017ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017bd:	8b 55 08             	mov    0x8(%ebp),%edx
801017c0:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801017c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c5:	8b 55 0c             	mov    0xc(%ebp),%edx
801017c8:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801017cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801017d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801017df:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801017e6:	e8 a2 33 00 00       	call   80104b8d <release>

  return ip;
801017eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801017ee:	c9                   	leave  
801017ef:	c3                   	ret    

801017f0 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801017f0:	55                   	push   %ebp
801017f1:	89 e5                	mov    %esp,%ebp
801017f3:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801017f6:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801017fd:	e8 29 33 00 00       	call   80104b2b <acquire>
  ip->ref++;
80101802:	8b 45 08             	mov    0x8(%ebp),%eax
80101805:	8b 40 08             	mov    0x8(%eax),%eax
80101808:	8d 50 01             	lea    0x1(%eax),%edx
8010180b:	8b 45 08             	mov    0x8(%ebp),%eax
8010180e:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101811:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101818:	e8 70 33 00 00       	call   80104b8d <release>
  return ip;
8010181d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101820:	c9                   	leave  
80101821:	c3                   	ret    

80101822 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101822:	55                   	push   %ebp
80101823:	89 e5                	mov    %esp,%ebp
80101825:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101828:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010182c:	74 0a                	je     80101838 <ilock+0x16>
8010182e:	8b 45 08             	mov    0x8(%ebp),%eax
80101831:	8b 40 08             	mov    0x8(%eax),%eax
80101834:	85 c0                	test   %eax,%eax
80101836:	7f 0c                	jg     80101844 <ilock+0x22>
    panic("ilock");
80101838:	c7 04 24 9f 82 10 80 	movl   $0x8010829f,(%esp)
8010183f:	e8 f2 ec ff ff       	call   80100536 <panic>

  acquire(&icache.lock);
80101844:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010184b:	e8 db 32 00 00       	call   80104b2b <acquire>
  while(ip->flags & I_BUSY)
80101850:	eb 13                	jmp    80101865 <ilock+0x43>
    sleep(ip, &icache.lock);
80101852:	c7 44 24 04 80 e8 10 	movl   $0x8010e880,0x4(%esp)
80101859:	80 
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	89 04 24             	mov    %eax,(%esp)
80101860:	e8 9e 2f 00 00       	call   80104803 <sleep>

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101865:	8b 45 08             	mov    0x8(%ebp),%eax
80101868:	8b 40 0c             	mov    0xc(%eax),%eax
8010186b:	83 e0 01             	and    $0x1,%eax
8010186e:	85 c0                	test   %eax,%eax
80101870:	75 e0                	jne    80101852 <ilock+0x30>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101872:	8b 45 08             	mov    0x8(%ebp),%eax
80101875:	8b 40 0c             	mov    0xc(%eax),%eax
80101878:	89 c2                	mov    %eax,%edx
8010187a:	83 ca 01             	or     $0x1,%edx
8010187d:	8b 45 08             	mov    0x8(%ebp),%eax
80101880:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101883:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
8010188a:	e8 fe 32 00 00       	call   80104b8d <release>

  if(!(ip->flags & I_VALID)){
8010188f:	8b 45 08             	mov    0x8(%ebp),%eax
80101892:	8b 40 0c             	mov    0xc(%eax),%eax
80101895:	83 e0 02             	and    $0x2,%eax
80101898:	85 c0                	test   %eax,%eax
8010189a:	0f 85 cb 00 00 00    	jne    8010196b <ilock+0x149>
    bp = bread(ip->dev, IBLOCK(ip->inum));
801018a0:	8b 45 08             	mov    0x8(%ebp),%eax
801018a3:	8b 40 04             	mov    0x4(%eax),%eax
801018a6:	c1 e8 03             	shr    $0x3,%eax
801018a9:	8d 50 02             	lea    0x2(%eax),%edx
801018ac:	8b 45 08             	mov    0x8(%ebp),%eax
801018af:	8b 00                	mov    (%eax),%eax
801018b1:	89 54 24 04          	mov    %edx,0x4(%esp)
801018b5:	89 04 24             	mov    %eax,(%esp)
801018b8:	e8 e9 e8 ff ff       	call   801001a6 <bread>
801018bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c3:	8d 50 18             	lea    0x18(%eax),%edx
801018c6:	8b 45 08             	mov    0x8(%ebp),%eax
801018c9:	8b 40 04             	mov    0x4(%eax),%eax
801018cc:	83 e0 07             	and    $0x7,%eax
801018cf:	c1 e0 06             	shl    $0x6,%eax
801018d2:	01 d0                	add    %edx,%eax
801018d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801018d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018da:	8b 00                	mov    (%eax),%eax
801018dc:	8b 55 08             	mov    0x8(%ebp),%edx
801018df:	66 89 42 10          	mov    %ax,0x10(%edx)
    ip->major = dip->major;
801018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e6:	66 8b 40 02          	mov    0x2(%eax),%ax
801018ea:	8b 55 08             	mov    0x8(%ebp),%edx
801018ed:	66 89 42 12          	mov    %ax,0x12(%edx)
    ip->minor = dip->minor;
801018f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f4:	8b 40 04             	mov    0x4(%eax),%eax
801018f7:	8b 55 08             	mov    0x8(%ebp),%edx
801018fa:	66 89 42 14          	mov    %ax,0x14(%edx)
    ip->nlink = dip->nlink;
801018fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101901:	66 8b 40 06          	mov    0x6(%eax),%ax
80101905:	8b 55 08             	mov    0x8(%ebp),%edx
80101908:	66 89 42 16          	mov    %ax,0x16(%edx)
    ip->size = dip->size;
8010190c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010190f:	8b 50 08             	mov    0x8(%eax),%edx
80101912:	8b 45 08             	mov    0x8(%ebp),%eax
80101915:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101918:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191b:	8d 50 0c             	lea    0xc(%eax),%edx
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	83 c0 1c             	add    $0x1c,%eax
80101924:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010192b:	00 
8010192c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101930:	89 04 24             	mov    %eax,(%esp)
80101933:	e8 12 35 00 00       	call   80104e4a <memmove>
    brelse(bp);
80101938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193b:	89 04 24             	mov    %eax,(%esp)
8010193e:	e8 d4 e8 ff ff       	call   80100217 <brelse>
    ip->flags |= I_VALID;
80101943:	8b 45 08             	mov    0x8(%ebp),%eax
80101946:	8b 40 0c             	mov    0xc(%eax),%eax
80101949:	89 c2                	mov    %eax,%edx
8010194b:	83 ca 02             	or     $0x2,%edx
8010194e:	8b 45 08             	mov    0x8(%ebp),%eax
80101951:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101954:	8b 45 08             	mov    0x8(%ebp),%eax
80101957:	8b 40 10             	mov    0x10(%eax),%eax
8010195a:	66 85 c0             	test   %ax,%ax
8010195d:	75 0c                	jne    8010196b <ilock+0x149>
      panic("ilock: no type");
8010195f:	c7 04 24 a5 82 10 80 	movl   $0x801082a5,(%esp)
80101966:	e8 cb eb ff ff       	call   80100536 <panic>
  }
}
8010196b:	c9                   	leave  
8010196c:	c3                   	ret    

8010196d <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
8010196d:	55                   	push   %ebp
8010196e:	89 e5                	mov    %esp,%ebp
80101970:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101973:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101977:	74 17                	je     80101990 <iunlock+0x23>
80101979:	8b 45 08             	mov    0x8(%ebp),%eax
8010197c:	8b 40 0c             	mov    0xc(%eax),%eax
8010197f:	83 e0 01             	and    $0x1,%eax
80101982:	85 c0                	test   %eax,%eax
80101984:	74 0a                	je     80101990 <iunlock+0x23>
80101986:	8b 45 08             	mov    0x8(%ebp),%eax
80101989:	8b 40 08             	mov    0x8(%eax),%eax
8010198c:	85 c0                	test   %eax,%eax
8010198e:	7f 0c                	jg     8010199c <iunlock+0x2f>
    panic("iunlock");
80101990:	c7 04 24 b4 82 10 80 	movl   $0x801082b4,(%esp)
80101997:	e8 9a eb ff ff       	call   80100536 <panic>

  acquire(&icache.lock);
8010199c:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801019a3:	e8 83 31 00 00       	call   80104b2b <acquire>
  ip->flags &= ~I_BUSY;
801019a8:	8b 45 08             	mov    0x8(%ebp),%eax
801019ab:	8b 40 0c             	mov    0xc(%eax),%eax
801019ae:	89 c2                	mov    %eax,%edx
801019b0:	83 e2 fe             	and    $0xfffffffe,%edx
801019b3:	8b 45 08             	mov    0x8(%ebp),%eax
801019b6:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
801019b9:	8b 45 08             	mov    0x8(%ebp),%eax
801019bc:	89 04 24             	mov    %eax,(%esp)
801019bf:	e8 1b 2f 00 00       	call   801048df <wakeup>
  release(&icache.lock);
801019c4:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801019cb:	e8 bd 31 00 00       	call   80104b8d <release>
}
801019d0:	c9                   	leave  
801019d1:	c3                   	ret    

801019d2 <iput>:
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
void
iput(struct inode *ip)
{
801019d2:	55                   	push   %ebp
801019d3:	89 e5                	mov    %esp,%ebp
801019d5:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801019d8:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
801019df:	e8 47 31 00 00       	call   80104b2b <acquire>
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
801019e4:	8b 45 08             	mov    0x8(%ebp),%eax
801019e7:	8b 40 08             	mov    0x8(%eax),%eax
801019ea:	83 f8 01             	cmp    $0x1,%eax
801019ed:	0f 85 93 00 00 00    	jne    80101a86 <iput+0xb4>
801019f3:	8b 45 08             	mov    0x8(%ebp),%eax
801019f6:	8b 40 0c             	mov    0xc(%eax),%eax
801019f9:	83 e0 02             	and    $0x2,%eax
801019fc:	85 c0                	test   %eax,%eax
801019fe:	0f 84 82 00 00 00    	je     80101a86 <iput+0xb4>
80101a04:	8b 45 08             	mov    0x8(%ebp),%eax
80101a07:	66 8b 40 16          	mov    0x16(%eax),%ax
80101a0b:	66 85 c0             	test   %ax,%ax
80101a0e:	75 76                	jne    80101a86 <iput+0xb4>
    // inode has no links: truncate and free inode.
    if(ip->flags & I_BUSY)
80101a10:	8b 45 08             	mov    0x8(%ebp),%eax
80101a13:	8b 40 0c             	mov    0xc(%eax),%eax
80101a16:	83 e0 01             	and    $0x1,%eax
80101a19:	85 c0                	test   %eax,%eax
80101a1b:	74 0c                	je     80101a29 <iput+0x57>
      panic("iput busy");
80101a1d:	c7 04 24 bc 82 10 80 	movl   $0x801082bc,(%esp)
80101a24:	e8 0d eb ff ff       	call   80100536 <panic>
    ip->flags |= I_BUSY;
80101a29:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2c:	8b 40 0c             	mov    0xc(%eax),%eax
80101a2f:	89 c2                	mov    %eax,%edx
80101a31:	83 ca 01             	or     $0x1,%edx
80101a34:	8b 45 08             	mov    0x8(%ebp),%eax
80101a37:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101a3a:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a41:	e8 47 31 00 00       	call   80104b8d <release>
    itrunc(ip);
80101a46:	8b 45 08             	mov    0x8(%ebp),%eax
80101a49:	89 04 24             	mov    %eax,(%esp)
80101a4c:	e8 7d 01 00 00       	call   80101bce <itrunc>
    ip->type = 0;
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101a5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a5d:	89 04 24             	mov    %eax,(%esp)
80101a60:	e8 03 fc ff ff       	call   80101668 <iupdate>
    acquire(&icache.lock);
80101a65:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a6c:	e8 ba 30 00 00       	call   80104b2b <acquire>
    ip->flags = 0;
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101a7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7e:	89 04 24             	mov    %eax,(%esp)
80101a81:	e8 59 2e 00 00       	call   801048df <wakeup>
  }
  ip->ref--;
80101a86:	8b 45 08             	mov    0x8(%ebp),%eax
80101a89:	8b 40 08             	mov    0x8(%eax),%eax
80101a8c:	8d 50 ff             	lea    -0x1(%eax),%edx
80101a8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a92:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a95:	c7 04 24 80 e8 10 80 	movl   $0x8010e880,(%esp)
80101a9c:	e8 ec 30 00 00       	call   80104b8d <release>
}
80101aa1:	c9                   	leave  
80101aa2:	c3                   	ret    

80101aa3 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101aa3:	55                   	push   %ebp
80101aa4:	89 e5                	mov    %esp,%ebp
80101aa6:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101aa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aac:	89 04 24             	mov    %eax,(%esp)
80101aaf:	e8 b9 fe ff ff       	call   8010196d <iunlock>
  iput(ip);
80101ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab7:	89 04 24             	mov    %eax,(%esp)
80101aba:	e8 13 ff ff ff       	call   801019d2 <iput>
}
80101abf:	c9                   	leave  
80101ac0:	c3                   	ret    

80101ac1 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101ac1:	55                   	push   %ebp
80101ac2:	89 e5                	mov    %esp,%ebp
80101ac4:	53                   	push   %ebx
80101ac5:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101ac8:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101acc:	77 3e                	ja     80101b0c <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ad4:	83 c2 04             	add    $0x4,%edx
80101ad7:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101adb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ade:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101ae2:	75 20                	jne    80101b04 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	8b 00                	mov    (%eax),%eax
80101ae9:	89 04 24             	mov    %eax,(%esp)
80101aec:	e8 5a f8 ff ff       	call   8010134b <balloc>
80101af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101af4:	8b 45 08             	mov    0x8(%ebp),%eax
80101af7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101afa:	8d 4a 04             	lea    0x4(%edx),%ecx
80101afd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b00:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b07:	e9 bc 00 00 00       	jmp    80101bc8 <bmap+0x107>
  }
  bn -= NDIRECT;
80101b0c:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101b10:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101b14:	0f 87 a2 00 00 00    	ja     80101bbc <bmap+0xfb>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b27:	75 19                	jne    80101b42 <bmap+0x81>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101b29:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2c:	8b 00                	mov    (%eax),%eax
80101b2e:	89 04 24             	mov    %eax,(%esp)
80101b31:	e8 15 f8 ff ff       	call   8010134b <balloc>
80101b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b39:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b3f:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101b42:	8b 45 08             	mov    0x8(%ebp),%eax
80101b45:	8b 00                	mov    (%eax),%eax
80101b47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101b4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b4e:	89 04 24             	mov    %eax,(%esp)
80101b51:	e8 50 e6 ff ff       	call   801001a6 <bread>
80101b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101b59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5c:	83 c0 18             	add    $0x18,%eax
80101b5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101b62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101b6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b6f:	01 d0                	add    %edx,%eax
80101b71:	8b 00                	mov    (%eax),%eax
80101b73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101b7a:	75 30                	jne    80101bac <bmap+0xeb>
      a[bn] = addr = balloc(ip->dev);
80101b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101b7f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101b86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101b89:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101b8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8f:	8b 00                	mov    (%eax),%eax
80101b91:	89 04 24             	mov    %eax,(%esp)
80101b94:	e8 b2 f7 ff ff       	call   8010134b <balloc>
80101b99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b9f:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba4:	89 04 24             	mov    %eax,(%esp)
80101ba7:	e8 a4 16 00 00       	call   80103250 <log_write>
    }
    brelse(bp);
80101bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101baf:	89 04 24             	mov    %eax,(%esp)
80101bb2:	e8 60 e6 ff ff       	call   80100217 <brelse>
    return addr;
80101bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101bba:	eb 0c                	jmp    80101bc8 <bmap+0x107>
  }

  panic("bmap: out of range");
80101bbc:	c7 04 24 c6 82 10 80 	movl   $0x801082c6,(%esp)
80101bc3:	e8 6e e9 ff ff       	call   80100536 <panic>
}
80101bc8:	83 c4 24             	add    $0x24,%esp
80101bcb:	5b                   	pop    %ebx
80101bcc:	5d                   	pop    %ebp
80101bcd:	c3                   	ret    

80101bce <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101bce:	55                   	push   %ebp
80101bcf:	89 e5                	mov    %esp,%ebp
80101bd1:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101bd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101bdb:	eb 43                	jmp    80101c20 <itrunc+0x52>
    if(ip->addrs[i]){
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101be3:	83 c2 04             	add    $0x4,%edx
80101be6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101bea:	85 c0                	test   %eax,%eax
80101bec:	74 2f                	je     80101c1d <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101bf4:	83 c2 04             	add    $0x4,%edx
80101bf7:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101bfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfe:	8b 00                	mov    (%eax),%eax
80101c00:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c04:	89 04 24             	mov    %eax,(%esp)
80101c07:	e8 90 f8 ff ff       	call   8010149c <bfree>
      ip->addrs[i] = 0;
80101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c12:	83 c2 04             	add    $0x4,%edx
80101c15:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101c1c:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101c1d:	ff 45 f4             	incl   -0xc(%ebp)
80101c20:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101c24:	7e b7                	jle    80101bdd <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101c26:	8b 45 08             	mov    0x8(%ebp),%eax
80101c29:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c2c:	85 c0                	test   %eax,%eax
80101c2e:	0f 84 9a 00 00 00    	je     80101cce <itrunc+0x100>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101c34:	8b 45 08             	mov    0x8(%ebp),%eax
80101c37:	8b 50 4c             	mov    0x4c(%eax),%edx
80101c3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c3d:	8b 00                	mov    (%eax),%eax
80101c3f:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c43:	89 04 24             	mov    %eax,(%esp)
80101c46:	e8 5b e5 ff ff       	call   801001a6 <bread>
80101c4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101c51:	83 c0 18             	add    $0x18,%eax
80101c54:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101c57:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101c5e:	eb 3a                	jmp    80101c9a <itrunc+0xcc>
      if(a[j])
80101c60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101c6d:	01 d0                	add    %edx,%eax
80101c6f:	8b 00                	mov    (%eax),%eax
80101c71:	85 c0                	test   %eax,%eax
80101c73:	74 22                	je     80101c97 <itrunc+0xc9>
        bfree(ip->dev, a[j]);
80101c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c78:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101c82:	01 d0                	add    %edx,%eax
80101c84:	8b 10                	mov    (%eax),%edx
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	8b 00                	mov    (%eax),%eax
80101c8b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101c8f:	89 04 24             	mov    %eax,(%esp)
80101c92:	e8 05 f8 ff ff       	call   8010149c <bfree>
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101c97:	ff 45 f0             	incl   -0x10(%ebp)
80101c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c9d:	83 f8 7f             	cmp    $0x7f,%eax
80101ca0:	76 be                	jbe    80101c60 <itrunc+0x92>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ca2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ca5:	89 04 24             	mov    %eax,(%esp)
80101ca8:	e8 6a e5 ff ff       	call   80100217 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	8b 50 4c             	mov    0x4c(%eax),%edx
80101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb6:	8b 00                	mov    (%eax),%eax
80101cb8:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cbc:	89 04 24             	mov    %eax,(%esp)
80101cbf:	e8 d8 f7 ff ff       	call   8010149c <bfree>
    ip->addrs[NDIRECT] = 0;
80101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101cce:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd1:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	89 04 24             	mov    %eax,(%esp)
80101cde:	e8 85 f9 ff ff       	call   80101668 <iupdate>
}
80101ce3:	c9                   	leave  
80101ce4:	c3                   	ret    

80101ce5 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101ce5:	55                   	push   %ebp
80101ce6:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ceb:	8b 00                	mov    (%eax),%eax
80101ced:	89 c2                	mov    %eax,%edx
80101cef:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf2:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf8:	8b 50 04             	mov    0x4(%eax),%edx
80101cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfe:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101d01:	8b 45 08             	mov    0x8(%ebp),%eax
80101d04:	8b 40 10             	mov    0x10(%eax),%eax
80101d07:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d0a:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101d0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d10:	66 8b 40 16          	mov    0x16(%eax),%ax
80101d14:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d17:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1e:	8b 50 18             	mov    0x18(%eax),%edx
80101d21:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d24:	89 50 10             	mov    %edx,0x10(%eax)
}
80101d27:	5d                   	pop    %ebp
80101d28:	c3                   	ret    

80101d29 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101d29:	55                   	push   %ebp
80101d2a:	89 e5                	mov    %esp,%ebp
80101d2c:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101d2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101d32:	8b 40 10             	mov    0x10(%eax),%eax
80101d35:	66 83 f8 03          	cmp    $0x3,%ax
80101d39:	75 60                	jne    80101d9b <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3e:	66 8b 40 12          	mov    0x12(%eax),%ax
80101d42:	66 85 c0             	test   %ax,%ax
80101d45:	78 20                	js     80101d67 <readi+0x3e>
80101d47:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4a:	66 8b 40 12          	mov    0x12(%eax),%ax
80101d4e:	66 83 f8 09          	cmp    $0x9,%ax
80101d52:	7f 13                	jg     80101d67 <readi+0x3e>
80101d54:	8b 45 08             	mov    0x8(%ebp),%eax
80101d57:	66 8b 40 12          	mov    0x12(%eax),%ax
80101d5b:	98                   	cwtl   
80101d5c:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80101d63:	85 c0                	test   %eax,%eax
80101d65:	75 0a                	jne    80101d71 <readi+0x48>
      return -1;
80101d67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101d6c:	e9 1b 01 00 00       	jmp    80101e8c <readi+0x163>
    return devsw[ip->major].read(ip, dst, n);
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	66 8b 40 12          	mov    0x12(%eax),%ax
80101d78:	98                   	cwtl   
80101d79:	8b 04 c5 20 e8 10 80 	mov    -0x7fef17e0(,%eax,8),%eax
80101d80:	8b 55 14             	mov    0x14(%ebp),%edx
80101d83:	89 54 24 08          	mov    %edx,0x8(%esp)
80101d87:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d8a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d8e:	8b 55 08             	mov    0x8(%ebp),%edx
80101d91:	89 14 24             	mov    %edx,(%esp)
80101d94:	ff d0                	call   *%eax
80101d96:	e9 f1 00 00 00       	jmp    80101e8c <readi+0x163>
  }

  if(off > ip->size || off + n < off)
80101d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9e:	8b 40 18             	mov    0x18(%eax),%eax
80101da1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101da4:	72 0d                	jb     80101db3 <readi+0x8a>
80101da6:	8b 45 14             	mov    0x14(%ebp),%eax
80101da9:	8b 55 10             	mov    0x10(%ebp),%edx
80101dac:	01 d0                	add    %edx,%eax
80101dae:	3b 45 10             	cmp    0x10(%ebp),%eax
80101db1:	73 0a                	jae    80101dbd <readi+0x94>
    return -1;
80101db3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101db8:	e9 cf 00 00 00       	jmp    80101e8c <readi+0x163>
  if(off + n > ip->size)
80101dbd:	8b 45 14             	mov    0x14(%ebp),%eax
80101dc0:	8b 55 10             	mov    0x10(%ebp),%edx
80101dc3:	01 c2                	add    %eax,%edx
80101dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc8:	8b 40 18             	mov    0x18(%eax),%eax
80101dcb:	39 c2                	cmp    %eax,%edx
80101dcd:	76 0c                	jbe    80101ddb <readi+0xb2>
    n = ip->size - off;
80101dcf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd2:	8b 40 18             	mov    0x18(%eax),%eax
80101dd5:	2b 45 10             	sub    0x10(%ebp),%eax
80101dd8:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ddb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101de2:	e9 96 00 00 00       	jmp    80101e7d <readi+0x154>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101de7:	8b 45 10             	mov    0x10(%ebp),%eax
80101dea:	c1 e8 09             	shr    $0x9,%eax
80101ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80101df1:	8b 45 08             	mov    0x8(%ebp),%eax
80101df4:	89 04 24             	mov    %eax,(%esp)
80101df7:	e8 c5 fc ff ff       	call   80101ac1 <bmap>
80101dfc:	8b 55 08             	mov    0x8(%ebp),%edx
80101dff:	8b 12                	mov    (%edx),%edx
80101e01:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e05:	89 14 24             	mov    %edx,(%esp)
80101e08:	e8 99 e3 ff ff       	call   801001a6 <bread>
80101e0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101e10:	8b 45 10             	mov    0x10(%ebp),%eax
80101e13:	89 c2                	mov    %eax,%edx
80101e15:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101e1b:	b8 00 02 00 00       	mov    $0x200,%eax
80101e20:	89 c1                	mov    %eax,%ecx
80101e22:	29 d1                	sub    %edx,%ecx
80101e24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e27:	8b 55 14             	mov    0x14(%ebp),%edx
80101e2a:	29 c2                	sub    %eax,%edx
80101e2c:	89 c8                	mov    %ecx,%eax
80101e2e:	39 d0                	cmp    %edx,%eax
80101e30:	76 02                	jbe    80101e34 <readi+0x10b>
80101e32:	89 d0                	mov    %edx,%eax
80101e34:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101e37:	8b 45 10             	mov    0x10(%ebp),%eax
80101e3a:	25 ff 01 00 00       	and    $0x1ff,%eax
80101e3f:	8d 50 10             	lea    0x10(%eax),%edx
80101e42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e45:	01 d0                	add    %edx,%eax
80101e47:	8d 50 08             	lea    0x8(%eax),%edx
80101e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80101e51:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e55:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e58:	89 04 24             	mov    %eax,(%esp)
80101e5b:	e8 ea 2f 00 00       	call   80104e4a <memmove>
    brelse(bp);
80101e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e63:	89 04 24             	mov    %eax,(%esp)
80101e66:	e8 ac e3 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101e6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e6e:	01 45 f4             	add    %eax,-0xc(%ebp)
80101e71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e74:	01 45 10             	add    %eax,0x10(%ebp)
80101e77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e7a:	01 45 0c             	add    %eax,0xc(%ebp)
80101e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e80:	3b 45 14             	cmp    0x14(%ebp),%eax
80101e83:	0f 82 5e ff ff ff    	jb     80101de7 <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101e89:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101e8c:	c9                   	leave  
80101e8d:	c3                   	ret    

80101e8e <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101e8e:	55                   	push   %ebp
80101e8f:	89 e5                	mov    %esp,%ebp
80101e91:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e94:	8b 45 08             	mov    0x8(%ebp),%eax
80101e97:	8b 40 10             	mov    0x10(%eax),%eax
80101e9a:	66 83 f8 03          	cmp    $0x3,%ax
80101e9e:	75 60                	jne    80101f00 <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	66 8b 40 12          	mov    0x12(%eax),%ax
80101ea7:	66 85 c0             	test   %ax,%ax
80101eaa:	78 20                	js     80101ecc <writei+0x3e>
80101eac:	8b 45 08             	mov    0x8(%ebp),%eax
80101eaf:	66 8b 40 12          	mov    0x12(%eax),%ax
80101eb3:	66 83 f8 09          	cmp    $0x9,%ax
80101eb7:	7f 13                	jg     80101ecc <writei+0x3e>
80101eb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebc:	66 8b 40 12          	mov    0x12(%eax),%ax
80101ec0:	98                   	cwtl   
80101ec1:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80101ec8:	85 c0                	test   %eax,%eax
80101eca:	75 0a                	jne    80101ed6 <writei+0x48>
      return -1;
80101ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ed1:	e9 46 01 00 00       	jmp    8010201c <writei+0x18e>
    return devsw[ip->major].write(ip, src, n);
80101ed6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed9:	66 8b 40 12          	mov    0x12(%eax),%ax
80101edd:	98                   	cwtl   
80101ede:	8b 04 c5 24 e8 10 80 	mov    -0x7fef17dc(,%eax,8),%eax
80101ee5:	8b 55 14             	mov    0x14(%ebp),%edx
80101ee8:	89 54 24 08          	mov    %edx,0x8(%esp)
80101eec:	8b 55 0c             	mov    0xc(%ebp),%edx
80101eef:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ef3:	8b 55 08             	mov    0x8(%ebp),%edx
80101ef6:	89 14 24             	mov    %edx,(%esp)
80101ef9:	ff d0                	call   *%eax
80101efb:	e9 1c 01 00 00       	jmp    8010201c <writei+0x18e>
  }

  if(off > ip->size || off + n < off)
80101f00:	8b 45 08             	mov    0x8(%ebp),%eax
80101f03:	8b 40 18             	mov    0x18(%eax),%eax
80101f06:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f09:	72 0d                	jb     80101f18 <writei+0x8a>
80101f0b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f0e:	8b 55 10             	mov    0x10(%ebp),%edx
80101f11:	01 d0                	add    %edx,%eax
80101f13:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f16:	73 0a                	jae    80101f22 <writei+0x94>
    return -1;
80101f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1d:	e9 fa 00 00 00       	jmp    8010201c <writei+0x18e>
  if(off + n > MAXFILE*BSIZE)
80101f22:	8b 45 14             	mov    0x14(%ebp),%eax
80101f25:	8b 55 10             	mov    0x10(%ebp),%edx
80101f28:	01 d0                	add    %edx,%eax
80101f2a:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101f2f:	76 0a                	jbe    80101f3b <writei+0xad>
    return -1;
80101f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f36:	e9 e1 00 00 00       	jmp    8010201c <writei+0x18e>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101f3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f42:	e9 a1 00 00 00       	jmp    80101fe8 <writei+0x15a>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f47:	8b 45 10             	mov    0x10(%ebp),%eax
80101f4a:	c1 e8 09             	shr    $0x9,%eax
80101f4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f51:	8b 45 08             	mov    0x8(%ebp),%eax
80101f54:	89 04 24             	mov    %eax,(%esp)
80101f57:	e8 65 fb ff ff       	call   80101ac1 <bmap>
80101f5c:	8b 55 08             	mov    0x8(%ebp),%edx
80101f5f:	8b 12                	mov    (%edx),%edx
80101f61:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f65:	89 14 24             	mov    %edx,(%esp)
80101f68:	e8 39 e2 ff ff       	call   801001a6 <bread>
80101f6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f70:	8b 45 10             	mov    0x10(%ebp),%eax
80101f73:	89 c2                	mov    %eax,%edx
80101f75:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80101f7b:	b8 00 02 00 00       	mov    $0x200,%eax
80101f80:	89 c1                	mov    %eax,%ecx
80101f82:	29 d1                	sub    %edx,%ecx
80101f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101f87:	8b 55 14             	mov    0x14(%ebp),%edx
80101f8a:	29 c2                	sub    %eax,%edx
80101f8c:	89 c8                	mov    %ecx,%eax
80101f8e:	39 d0                	cmp    %edx,%eax
80101f90:	76 02                	jbe    80101f94 <writei+0x106>
80101f92:	89 d0                	mov    %edx,%eax
80101f94:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80101f97:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9a:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f9f:	8d 50 10             	lea    0x10(%eax),%edx
80101fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fa5:	01 d0                	add    %edx,%eax
80101fa7:	8d 50 08             	lea    0x8(%eax),%edx
80101faa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fad:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb4:	89 44 24 04          	mov    %eax,0x4(%esp)
80101fb8:	89 14 24             	mov    %edx,(%esp)
80101fbb:	e8 8a 2e 00 00       	call   80104e4a <memmove>
    log_write(bp);
80101fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc3:	89 04 24             	mov    %eax,(%esp)
80101fc6:	e8 85 12 00 00       	call   80103250 <log_write>
    brelse(bp);
80101fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fce:	89 04 24             	mov    %eax,(%esp)
80101fd1:	e8 41 e2 ff ff       	call   80100217 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101fd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fd9:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fdf:	01 45 10             	add    %eax,0x10(%ebp)
80101fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe5:	01 45 0c             	add    %eax,0xc(%ebp)
80101fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101feb:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fee:	0f 82 53 ff ff ff    	jb     80101f47 <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80101ff4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80101ff8:	74 1f                	je     80102019 <writei+0x18b>
80101ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffd:	8b 40 18             	mov    0x18(%eax),%eax
80102000:	3b 45 10             	cmp    0x10(%ebp),%eax
80102003:	73 14                	jae    80102019 <writei+0x18b>
    ip->size = off;
80102005:	8b 45 08             	mov    0x8(%ebp),%eax
80102008:	8b 55 10             	mov    0x10(%ebp),%edx
8010200b:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010200e:	8b 45 08             	mov    0x8(%ebp),%eax
80102011:	89 04 24             	mov    %eax,(%esp)
80102014:	e8 4f f6 ff ff       	call   80101668 <iupdate>
  }
  return n;
80102019:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010201c:	c9                   	leave  
8010201d:	c3                   	ret    

8010201e <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010201e:	55                   	push   %ebp
8010201f:	89 e5                	mov    %esp,%ebp
80102021:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102024:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010202b:	00 
8010202c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010202f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	89 04 24             	mov    %eax,(%esp)
80102039:	e8 a8 2e 00 00       	call   80104ee6 <strncmp>
}
8010203e:	c9                   	leave  
8010203f:	c3                   	ret    

80102040 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102040:	55                   	push   %ebp
80102041:	89 e5                	mov    %esp,%ebp
80102043:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	8b 40 10             	mov    0x10(%eax),%eax
8010204c:	66 83 f8 01          	cmp    $0x1,%ax
80102050:	74 0c                	je     8010205e <dirlookup+0x1e>
    panic("dirlookup not DIR");
80102052:	c7 04 24 d9 82 10 80 	movl   $0x801082d9,(%esp)
80102059:	e8 d8 e4 ff ff       	call   80100536 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010205e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102065:	e9 85 00 00 00       	jmp    801020ef <dirlookup+0xaf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010206a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102071:	00 
80102072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102075:	89 44 24 08          	mov    %eax,0x8(%esp)
80102079:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010207c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102080:	8b 45 08             	mov    0x8(%ebp),%eax
80102083:	89 04 24             	mov    %eax,(%esp)
80102086:	e8 9e fc ff ff       	call   80101d29 <readi>
8010208b:	83 f8 10             	cmp    $0x10,%eax
8010208e:	74 0c                	je     8010209c <dirlookup+0x5c>
      panic("dirlink read");
80102090:	c7 04 24 eb 82 10 80 	movl   $0x801082eb,(%esp)
80102097:	e8 9a e4 ff ff       	call   80100536 <panic>
    if(de.inum == 0)
8010209c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010209f:	66 85 c0             	test   %ax,%ax
801020a2:	74 46                	je     801020ea <dirlookup+0xaa>
      continue;
    if(namecmp(name, de.name) == 0){
801020a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801020a7:	83 c0 02             	add    $0x2,%eax
801020aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801020ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801020b1:	89 04 24             	mov    %eax,(%esp)
801020b4:	e8 65 ff ff ff       	call   8010201e <namecmp>
801020b9:	85 c0                	test   %eax,%eax
801020bb:	75 2e                	jne    801020eb <dirlookup+0xab>
      // entry matches path element
      if(poff)
801020bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801020c1:	74 08                	je     801020cb <dirlookup+0x8b>
        *poff = off;
801020c3:	8b 45 10             	mov    0x10(%ebp),%eax
801020c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801020c9:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801020cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801020ce:	0f b7 c0             	movzwl %ax,%eax
801020d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801020d4:	8b 45 08             	mov    0x8(%ebp),%eax
801020d7:	8b 00                	mov    (%eax),%eax
801020d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801020dc:	89 54 24 04          	mov    %edx,0x4(%esp)
801020e0:	89 04 24             	mov    %eax,(%esp)
801020e3:	e8 36 f6 ff ff       	call   8010171e <iget>
801020e8:	eb 19                	jmp    80102103 <dirlookup+0xc3>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
801020ea:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801020eb:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801020ef:	8b 45 08             	mov    0x8(%ebp),%eax
801020f2:	8b 40 18             	mov    0x18(%eax),%eax
801020f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801020f8:	0f 87 6c ff ff ff    	ja     8010206a <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801020fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102103:	c9                   	leave  
80102104:	c3                   	ret    

80102105 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102105:	55                   	push   %ebp
80102106:	89 e5                	mov    %esp,%ebp
80102108:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010210b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102112:	00 
80102113:	8b 45 0c             	mov    0xc(%ebp),%eax
80102116:	89 44 24 04          	mov    %eax,0x4(%esp)
8010211a:	8b 45 08             	mov    0x8(%ebp),%eax
8010211d:	89 04 24             	mov    %eax,(%esp)
80102120:	e8 1b ff ff ff       	call   80102040 <dirlookup>
80102125:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102128:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010212c:	74 15                	je     80102143 <dirlink+0x3e>
    iput(ip);
8010212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102131:	89 04 24             	mov    %eax,(%esp)
80102134:	e8 99 f8 ff ff       	call   801019d2 <iput>
    return -1;
80102139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010213e:	e9 b7 00 00 00       	jmp    801021fa <dirlink+0xf5>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102143:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010214a:	eb 43                	jmp    8010218f <dirlink+0x8a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010214c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010214f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102156:	00 
80102157:	89 44 24 08          	mov    %eax,0x8(%esp)
8010215b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010215e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102162:	8b 45 08             	mov    0x8(%ebp),%eax
80102165:	89 04 24             	mov    %eax,(%esp)
80102168:	e8 bc fb ff ff       	call   80101d29 <readi>
8010216d:	83 f8 10             	cmp    $0x10,%eax
80102170:	74 0c                	je     8010217e <dirlink+0x79>
      panic("dirlink read");
80102172:	c7 04 24 eb 82 10 80 	movl   $0x801082eb,(%esp)
80102179:	e8 b8 e3 ff ff       	call   80100536 <panic>
    if(de.inum == 0)
8010217e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102181:	66 85 c0             	test   %ax,%ax
80102184:	74 18                	je     8010219e <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102186:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102189:	83 c0 10             	add    $0x10,%eax
8010218c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010218f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	8b 40 18             	mov    0x18(%eax),%eax
80102198:	39 c2                	cmp    %eax,%edx
8010219a:	72 b0                	jb     8010214c <dirlink+0x47>
8010219c:	eb 01                	jmp    8010219f <dirlink+0x9a>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
8010219e:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010219f:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021a6:	00 
801021a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801021aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801021ae:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021b1:	83 c0 02             	add    $0x2,%eax
801021b4:	89 04 24             	mov    %eax,(%esp)
801021b7:	e8 7a 2d 00 00       	call   80104f36 <strncpy>
  de.inum = inum;
801021bc:	8b 45 10             	mov    0x10(%ebp),%eax
801021bf:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021c6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801021cd:	00 
801021ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801021d2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801021d9:	8b 45 08             	mov    0x8(%ebp),%eax
801021dc:	89 04 24             	mov    %eax,(%esp)
801021df:	e8 aa fc ff ff       	call   80101e8e <writei>
801021e4:	83 f8 10             	cmp    $0x10,%eax
801021e7:	74 0c                	je     801021f5 <dirlink+0xf0>
    panic("dirlink");
801021e9:	c7 04 24 f8 82 10 80 	movl   $0x801082f8,(%esp)
801021f0:	e8 41 e3 ff ff       	call   80100536 <panic>
  
  return 0;
801021f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801021fa:	c9                   	leave  
801021fb:	c3                   	ret    

801021fc <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801021fc:	55                   	push   %ebp
801021fd:	89 e5                	mov    %esp,%ebp
801021ff:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102202:	eb 03                	jmp    80102207 <skipelem+0xb>
    path++;
80102204:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102207:	8b 45 08             	mov    0x8(%ebp),%eax
8010220a:	8a 00                	mov    (%eax),%al
8010220c:	3c 2f                	cmp    $0x2f,%al
8010220e:	74 f4                	je     80102204 <skipelem+0x8>
    path++;
  if(*path == 0)
80102210:	8b 45 08             	mov    0x8(%ebp),%eax
80102213:	8a 00                	mov    (%eax),%al
80102215:	84 c0                	test   %al,%al
80102217:	75 0a                	jne    80102223 <skipelem+0x27>
    return 0;
80102219:	b8 00 00 00 00       	mov    $0x0,%eax
8010221e:	e9 83 00 00 00       	jmp    801022a6 <skipelem+0xaa>
  s = path;
80102223:	8b 45 08             	mov    0x8(%ebp),%eax
80102226:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102229:	eb 03                	jmp    8010222e <skipelem+0x32>
    path++;
8010222b:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010222e:	8b 45 08             	mov    0x8(%ebp),%eax
80102231:	8a 00                	mov    (%eax),%al
80102233:	3c 2f                	cmp    $0x2f,%al
80102235:	74 09                	je     80102240 <skipelem+0x44>
80102237:	8b 45 08             	mov    0x8(%ebp),%eax
8010223a:	8a 00                	mov    (%eax),%al
8010223c:	84 c0                	test   %al,%al
8010223e:	75 eb                	jne    8010222b <skipelem+0x2f>
    path++;
  len = path - s;
80102240:	8b 55 08             	mov    0x8(%ebp),%edx
80102243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102246:	89 d1                	mov    %edx,%ecx
80102248:	29 c1                	sub    %eax,%ecx
8010224a:	89 c8                	mov    %ecx,%eax
8010224c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010224f:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102253:	7e 1c                	jle    80102271 <skipelem+0x75>
    memmove(name, s, DIRSIZ);
80102255:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010225c:	00 
8010225d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102260:	89 44 24 04          	mov    %eax,0x4(%esp)
80102264:	8b 45 0c             	mov    0xc(%ebp),%eax
80102267:	89 04 24             	mov    %eax,(%esp)
8010226a:	e8 db 2b 00 00       	call   80104e4a <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010226f:	eb 29                	jmp    8010229a <skipelem+0x9e>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102271:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102274:	89 44 24 08          	mov    %eax,0x8(%esp)
80102278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010227b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010227f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102282:	89 04 24             	mov    %eax,(%esp)
80102285:	e8 c0 2b 00 00       	call   80104e4a <memmove>
    name[len] = 0;
8010228a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010228d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102290:	01 d0                	add    %edx,%eax
80102292:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102295:	eb 03                	jmp    8010229a <skipelem+0x9e>
    path++;
80102297:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010229a:	8b 45 08             	mov    0x8(%ebp),%eax
8010229d:	8a 00                	mov    (%eax),%al
8010229f:	3c 2f                	cmp    $0x2f,%al
801022a1:	74 f4                	je     80102297 <skipelem+0x9b>
    path++;
  return path;
801022a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801022a6:	c9                   	leave  
801022a7:	c3                   	ret    

801022a8 <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801022a8:	55                   	push   %ebp
801022a9:	89 e5                	mov    %esp,%ebp
801022ab:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801022ae:	8b 45 08             	mov    0x8(%ebp),%eax
801022b1:	8a 00                	mov    (%eax),%al
801022b3:	3c 2f                	cmp    $0x2f,%al
801022b5:	75 1c                	jne    801022d3 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801022b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801022be:	00 
801022bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801022c6:	e8 53 f4 ff ff       	call   8010171e <iget>
801022cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801022ce:	e9 ad 00 00 00       	jmp    80102380 <namex+0xd8>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);
801022d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801022d9:	8b 40 68             	mov    0x68(%eax),%eax
801022dc:	89 04 24             	mov    %eax,(%esp)
801022df:	e8 0c f5 ff ff       	call   801017f0 <idup>
801022e4:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801022e7:	e9 94 00 00 00       	jmp    80102380 <namex+0xd8>
    ilock(ip);
801022ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ef:	89 04 24             	mov    %eax,(%esp)
801022f2:	e8 2b f5 ff ff       	call   80101822 <ilock>
    if(ip->type != T_DIR){
801022f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022fa:	8b 40 10             	mov    0x10(%eax),%eax
801022fd:	66 83 f8 01          	cmp    $0x1,%ax
80102301:	74 15                	je     80102318 <namex+0x70>
      iunlockput(ip);
80102303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102306:	89 04 24             	mov    %eax,(%esp)
80102309:	e8 95 f7 ff ff       	call   80101aa3 <iunlockput>
      return 0;
8010230e:	b8 00 00 00 00       	mov    $0x0,%eax
80102313:	e9 a2 00 00 00       	jmp    801023ba <namex+0x112>
    }
    if(nameiparent && *path == '\0'){
80102318:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010231c:	74 1c                	je     8010233a <namex+0x92>
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8a 00                	mov    (%eax),%al
80102323:	84 c0                	test   %al,%al
80102325:	75 13                	jne    8010233a <namex+0x92>
      // Stop one level early.
      iunlock(ip);
80102327:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010232a:	89 04 24             	mov    %eax,(%esp)
8010232d:	e8 3b f6 ff ff       	call   8010196d <iunlock>
      return ip;
80102332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102335:	e9 80 00 00 00       	jmp    801023ba <namex+0x112>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010233a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102341:	00 
80102342:	8b 45 10             	mov    0x10(%ebp),%eax
80102345:	89 44 24 04          	mov    %eax,0x4(%esp)
80102349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234c:	89 04 24             	mov    %eax,(%esp)
8010234f:	e8 ec fc ff ff       	call   80102040 <dirlookup>
80102354:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102357:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010235b:	75 12                	jne    8010236f <namex+0xc7>
      iunlockput(ip);
8010235d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102360:	89 04 24             	mov    %eax,(%esp)
80102363:	e8 3b f7 ff ff       	call   80101aa3 <iunlockput>
      return 0;
80102368:	b8 00 00 00 00       	mov    $0x0,%eax
8010236d:	eb 4b                	jmp    801023ba <namex+0x112>
    }
    iunlockput(ip);
8010236f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102372:	89 04 24             	mov    %eax,(%esp)
80102375:	e8 29 f7 ff ff       	call   80101aa3 <iunlockput>
    ip = next;
8010237a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010237d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102380:	8b 45 10             	mov    0x10(%ebp),%eax
80102383:	89 44 24 04          	mov    %eax,0x4(%esp)
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	89 04 24             	mov    %eax,(%esp)
8010238d:	e8 6a fe ff ff       	call   801021fc <skipelem>
80102392:	89 45 08             	mov    %eax,0x8(%ebp)
80102395:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102399:	0f 85 4d ff ff ff    	jne    801022ec <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010239f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801023a3:	74 12                	je     801023b7 <namex+0x10f>
    iput(ip);
801023a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a8:	89 04 24             	mov    %eax,(%esp)
801023ab:	e8 22 f6 ff ff       	call   801019d2 <iput>
    return 0;
801023b0:	b8 00 00 00 00       	mov    $0x0,%eax
801023b5:	eb 03                	jmp    801023ba <namex+0x112>
  }
  return ip;
801023b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801023ba:	c9                   	leave  
801023bb:	c3                   	ret    

801023bc <namei>:

struct inode*
namei(char *path)
{
801023bc:	55                   	push   %ebp
801023bd:	89 e5                	mov    %esp,%ebp
801023bf:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801023c2:	8d 45 ea             	lea    -0x16(%ebp),%eax
801023c5:	89 44 24 08          	mov    %eax,0x8(%esp)
801023c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801023d0:	00 
801023d1:	8b 45 08             	mov    0x8(%ebp),%eax
801023d4:	89 04 24             	mov    %eax,(%esp)
801023d7:	e8 cc fe ff ff       	call   801022a8 <namex>
}
801023dc:	c9                   	leave  
801023dd:	c3                   	ret    

801023de <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801023de:	55                   	push   %ebp
801023df:	89 e5                	mov    %esp,%ebp
801023e1:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801023e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801023e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801023eb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801023f2:	00 
801023f3:	8b 45 08             	mov    0x8(%ebp),%eax
801023f6:	89 04 24             	mov    %eax,(%esp)
801023f9:	e8 aa fe ff ff       	call   801022a8 <namex>
}
801023fe:	c9                   	leave  
801023ff:	c3                   	ret    

80102400 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102400:	55                   	push   %ebp
80102401:	89 e5                	mov    %esp,%ebp
80102403:	53                   	push   %ebx
80102404:	83 ec 14             	sub    $0x14,%esp
80102407:	8b 45 08             	mov    0x8(%ebp),%eax
8010240a:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010240e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102411:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102415:	66 8b 55 ea          	mov    -0x16(%ebp),%dx
80102419:	ec                   	in     (%dx),%al
8010241a:	88 c3                	mov    %al,%bl
8010241c:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
8010241f:	8a 45 fb             	mov    -0x5(%ebp),%al
}
80102422:	83 c4 14             	add    $0x14,%esp
80102425:	5b                   	pop    %ebx
80102426:	5d                   	pop    %ebp
80102427:	c3                   	ret    

80102428 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102428:	55                   	push   %ebp
80102429:	89 e5                	mov    %esp,%ebp
8010242b:	57                   	push   %edi
8010242c:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010242d:	8b 55 08             	mov    0x8(%ebp),%edx
80102430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102433:	8b 45 10             	mov    0x10(%ebp),%eax
80102436:	89 cb                	mov    %ecx,%ebx
80102438:	89 df                	mov    %ebx,%edi
8010243a:	89 c1                	mov    %eax,%ecx
8010243c:	fc                   	cld    
8010243d:	f3 6d                	rep insl (%dx),%es:(%edi)
8010243f:	89 c8                	mov    %ecx,%eax
80102441:	89 fb                	mov    %edi,%ebx
80102443:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102446:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102449:	5b                   	pop    %ebx
8010244a:	5f                   	pop    %edi
8010244b:	5d                   	pop    %ebp
8010244c:	c3                   	ret    

8010244d <outb>:

static inline void
outb(ushort port, uchar data)
{
8010244d:	55                   	push   %ebp
8010244e:	89 e5                	mov    %esp,%ebp
80102450:	83 ec 08             	sub    $0x8,%esp
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
80102456:	8b 55 0c             	mov    0xc(%ebp),%edx
80102459:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010245d:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102460:	8a 45 f8             	mov    -0x8(%ebp),%al
80102463:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102466:	ee                   	out    %al,(%dx)
}
80102467:	c9                   	leave  
80102468:	c3                   	ret    

80102469 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102469:	55                   	push   %ebp
8010246a:	89 e5                	mov    %esp,%ebp
8010246c:	56                   	push   %esi
8010246d:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010246e:	8b 55 08             	mov    0x8(%ebp),%edx
80102471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102474:	8b 45 10             	mov    0x10(%ebp),%eax
80102477:	89 cb                	mov    %ecx,%ebx
80102479:	89 de                	mov    %ebx,%esi
8010247b:	89 c1                	mov    %eax,%ecx
8010247d:	fc                   	cld    
8010247e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102480:	89 c8                	mov    %ecx,%eax
80102482:	89 f3                	mov    %esi,%ebx
80102484:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102487:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010248a:	5b                   	pop    %ebx
8010248b:	5e                   	pop    %esi
8010248c:	5d                   	pop    %ebp
8010248d:	c3                   	ret    

8010248e <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010248e:	55                   	push   %ebp
8010248f:	89 e5                	mov    %esp,%ebp
80102491:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102494:	90                   	nop
80102495:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010249c:	e8 5f ff ff ff       	call   80102400 <inb>
801024a1:	0f b6 c0             	movzbl %al,%eax
801024a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
801024a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024aa:	25 c0 00 00 00       	and    $0xc0,%eax
801024af:	83 f8 40             	cmp    $0x40,%eax
801024b2:	75 e1                	jne    80102495 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801024b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024b8:	74 11                	je     801024cb <idewait+0x3d>
801024ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801024bd:	83 e0 21             	and    $0x21,%eax
801024c0:	85 c0                	test   %eax,%eax
801024c2:	74 07                	je     801024cb <idewait+0x3d>
    return -1;
801024c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801024c9:	eb 05                	jmp    801024d0 <idewait+0x42>
  return 0;
801024cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801024d0:	c9                   	leave  
801024d1:	c3                   	ret    

801024d2 <ideinit>:

void
ideinit(void)
{
801024d2:	55                   	push   %ebp
801024d3:	89 e5                	mov    %esp,%ebp
801024d5:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801024d8:	c7 44 24 04 00 83 10 	movl   $0x80108300,0x4(%esp)
801024df:	80 
801024e0:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801024e7:	e8 1e 26 00 00       	call   80104b0a <initlock>
  picenable(IRQ_IDE);
801024ec:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801024f3:	e8 8c 15 00 00       	call   80103a84 <picenable>
  ioapicenable(IRQ_IDE, ncpu - 1);
801024f8:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801024fd:	48                   	dec    %eax
801024fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80102502:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102509:	e8 0b 04 00 00       	call   80102919 <ioapicenable>
  idewait(0);
8010250e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102515:	e8 74 ff ff ff       	call   8010248e <idewait>
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010251a:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102521:	00 
80102522:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102529:	e8 1f ff ff ff       	call   8010244d <outb>
  for(i=0; i<1000; i++){
8010252e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102535:	eb 1f                	jmp    80102556 <ideinit+0x84>
    if(inb(0x1f7) != 0){
80102537:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010253e:	e8 bd fe ff ff       	call   80102400 <inb>
80102543:	84 c0                	test   %al,%al
80102545:	74 0c                	je     80102553 <ideinit+0x81>
      havedisk1 = 1;
80102547:	c7 05 58 b6 10 80 01 	movl   $0x1,0x8010b658
8010254e:	00 00 00 
      break;
80102551:	eb 0c                	jmp    8010255f <ideinit+0x8d>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102553:	ff 45 f4             	incl   -0xc(%ebp)
80102556:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010255d:	7e d8                	jle    80102537 <ideinit+0x65>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010255f:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102566:	00 
80102567:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010256e:	e8 da fe ff ff       	call   8010244d <outb>
}
80102573:	c9                   	leave  
80102574:	c3                   	ret    

80102575 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102575:	55                   	push   %ebp
80102576:	89 e5                	mov    %esp,%ebp
80102578:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
8010257b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010257f:	75 0c                	jne    8010258d <idestart+0x18>
    panic("idestart");
80102581:	c7 04 24 04 83 10 80 	movl   $0x80108304,(%esp)
80102588:	e8 a9 df ff ff       	call   80100536 <panic>

  idewait(0);
8010258d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102594:	e8 f5 fe ff ff       	call   8010248e <idewait>
  outb(0x3f6, 0);  // generate interrupt
80102599:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025a0:	00 
801025a1:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801025a8:	e8 a0 fe ff ff       	call   8010244d <outb>
  outb(0x1f2, 1);  // number of sectors
801025ad:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025b4:	00 
801025b5:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801025bc:	e8 8c fe ff ff       	call   8010244d <outb>
  outb(0x1f3, b->sector & 0xff);
801025c1:	8b 45 08             	mov    0x8(%ebp),%eax
801025c4:	8b 40 08             	mov    0x8(%eax),%eax
801025c7:	0f b6 c0             	movzbl %al,%eax
801025ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ce:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801025d5:	e8 73 fe ff ff       	call   8010244d <outb>
  outb(0x1f4, (b->sector >> 8) & 0xff);
801025da:	8b 45 08             	mov    0x8(%ebp),%eax
801025dd:	8b 40 08             	mov    0x8(%eax),%eax
801025e0:	c1 e8 08             	shr    $0x8,%eax
801025e3:	0f b6 c0             	movzbl %al,%eax
801025e6:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ea:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801025f1:	e8 57 fe ff ff       	call   8010244d <outb>
  outb(0x1f5, (b->sector >> 16) & 0xff);
801025f6:	8b 45 08             	mov    0x8(%ebp),%eax
801025f9:	8b 40 08             	mov    0x8(%eax),%eax
801025fc:	c1 e8 10             	shr    $0x10,%eax
801025ff:	0f b6 c0             	movzbl %al,%eax
80102602:	89 44 24 04          	mov    %eax,0x4(%esp)
80102606:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010260d:	e8 3b fe ff ff       	call   8010244d <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102612:	8b 45 08             	mov    0x8(%ebp),%eax
80102615:	8b 40 04             	mov    0x4(%eax),%eax
80102618:	83 e0 01             	and    $0x1,%eax
8010261b:	88 c2                	mov    %al,%dl
8010261d:	c1 e2 04             	shl    $0x4,%edx
80102620:	8b 45 08             	mov    0x8(%ebp),%eax
80102623:	8b 40 08             	mov    0x8(%eax),%eax
80102626:	c1 e8 18             	shr    $0x18,%eax
80102629:	83 e0 0f             	and    $0xf,%eax
8010262c:	09 d0                	or     %edx,%eax
8010262e:	83 c8 e0             	or     $0xffffffe0,%eax
80102631:	0f b6 c0             	movzbl %al,%eax
80102634:	89 44 24 04          	mov    %eax,0x4(%esp)
80102638:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010263f:	e8 09 fe ff ff       	call   8010244d <outb>
  if(b->flags & B_DIRTY){
80102644:	8b 45 08             	mov    0x8(%ebp),%eax
80102647:	8b 00                	mov    (%eax),%eax
80102649:	83 e0 04             	and    $0x4,%eax
8010264c:	85 c0                	test   %eax,%eax
8010264e:	74 34                	je     80102684 <idestart+0x10f>
    outb(0x1f7, IDE_CMD_WRITE);
80102650:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80102657:	00 
80102658:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010265f:	e8 e9 fd ff ff       	call   8010244d <outb>
    outsl(0x1f0, b->data, 512/4);
80102664:	8b 45 08             	mov    0x8(%ebp),%eax
80102667:	83 c0 18             	add    $0x18,%eax
8010266a:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102671:	00 
80102672:	89 44 24 04          	mov    %eax,0x4(%esp)
80102676:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010267d:	e8 e7 fd ff ff       	call   80102469 <outsl>
80102682:	eb 14                	jmp    80102698 <idestart+0x123>
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102684:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
8010268b:	00 
8010268c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102693:	e8 b5 fd ff ff       	call   8010244d <outb>
  }
}
80102698:	c9                   	leave  
80102699:	c3                   	ret    

8010269a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010269a:	55                   	push   %ebp
8010269b:	89 e5                	mov    %esp,%ebp
8010269d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801026a0:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801026a7:	e8 7f 24 00 00       	call   80104b2b <acquire>
  if((b = idequeue) == 0){
801026ac:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801026b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801026b8:	75 11                	jne    801026cb <ideintr+0x31>
    release(&idelock);
801026ba:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801026c1:	e8 c7 24 00 00       	call   80104b8d <release>
    // cprintf("spurious IDE interrupt\n");
    return;
801026c6:	e9 90 00 00 00       	jmp    8010275b <ideintr+0xc1>
  }
  idequeue = b->qnext;
801026cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ce:	8b 40 14             	mov    0x14(%eax),%eax
801026d1:	a3 54 b6 10 80       	mov    %eax,0x8010b654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801026d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d9:	8b 00                	mov    (%eax),%eax
801026db:	83 e0 04             	and    $0x4,%eax
801026de:	85 c0                	test   %eax,%eax
801026e0:	75 2e                	jne    80102710 <ideintr+0x76>
801026e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801026e9:	e8 a0 fd ff ff       	call   8010248e <idewait>
801026ee:	85 c0                	test   %eax,%eax
801026f0:	78 1e                	js     80102710 <ideintr+0x76>
    insl(0x1f0, b->data, 512/4);
801026f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f5:	83 c0 18             	add    $0x18,%eax
801026f8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801026ff:	00 
80102700:	89 44 24 04          	mov    %eax,0x4(%esp)
80102704:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010270b:	e8 18 fd ff ff       	call   80102428 <insl>
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102710:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102713:	8b 00                	mov    (%eax),%eax
80102715:	89 c2                	mov    %eax,%edx
80102717:	83 ca 02             	or     $0x2,%edx
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010271f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102722:	8b 00                	mov    (%eax),%eax
80102724:	89 c2                	mov    %eax,%edx
80102726:	83 e2 fb             	and    $0xfffffffb,%edx
80102729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010272e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102731:	89 04 24             	mov    %eax,(%esp)
80102734:	e8 a6 21 00 00       	call   801048df <wakeup>
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102739:	a1 54 b6 10 80       	mov    0x8010b654,%eax
8010273e:	85 c0                	test   %eax,%eax
80102740:	74 0d                	je     8010274f <ideintr+0xb5>
    idestart(idequeue);
80102742:	a1 54 b6 10 80       	mov    0x8010b654,%eax
80102747:	89 04 24             	mov    %eax,(%esp)
8010274a:	e8 26 fe ff ff       	call   80102575 <idestart>

  release(&idelock);
8010274f:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
80102756:	e8 32 24 00 00       	call   80104b8d <release>
}
8010275b:	c9                   	leave  
8010275c:	c3                   	ret    

8010275d <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010275d:	55                   	push   %ebp
8010275e:	89 e5                	mov    %esp,%ebp
80102760:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102763:	8b 45 08             	mov    0x8(%ebp),%eax
80102766:	8b 00                	mov    (%eax),%eax
80102768:	83 e0 01             	and    $0x1,%eax
8010276b:	85 c0                	test   %eax,%eax
8010276d:	75 0c                	jne    8010277b <iderw+0x1e>
    panic("iderw: buf not busy");
8010276f:	c7 04 24 0d 83 10 80 	movl   $0x8010830d,(%esp)
80102776:	e8 bb dd ff ff       	call   80100536 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010277b:	8b 45 08             	mov    0x8(%ebp),%eax
8010277e:	8b 00                	mov    (%eax),%eax
80102780:	83 e0 06             	and    $0x6,%eax
80102783:	83 f8 02             	cmp    $0x2,%eax
80102786:	75 0c                	jne    80102794 <iderw+0x37>
    panic("iderw: nothing to do");
80102788:	c7 04 24 21 83 10 80 	movl   $0x80108321,(%esp)
8010278f:	e8 a2 dd ff ff       	call   80100536 <panic>
  if(b->dev != 0 && !havedisk1)
80102794:	8b 45 08             	mov    0x8(%ebp),%eax
80102797:	8b 40 04             	mov    0x4(%eax),%eax
8010279a:	85 c0                	test   %eax,%eax
8010279c:	74 15                	je     801027b3 <iderw+0x56>
8010279e:	a1 58 b6 10 80       	mov    0x8010b658,%eax
801027a3:	85 c0                	test   %eax,%eax
801027a5:	75 0c                	jne    801027b3 <iderw+0x56>
    panic("iderw: ide disk 1 not present");
801027a7:	c7 04 24 36 83 10 80 	movl   $0x80108336,(%esp)
801027ae:	e8 83 dd ff ff       	call   80100536 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801027b3:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
801027ba:	e8 6c 23 00 00       	call   80104b2b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801027bf:	8b 45 08             	mov    0x8(%ebp),%eax
801027c2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801027c9:	c7 45 f4 54 b6 10 80 	movl   $0x8010b654,-0xc(%ebp)
801027d0:	eb 0b                	jmp    801027dd <iderw+0x80>
801027d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d5:	8b 00                	mov    (%eax),%eax
801027d7:	83 c0 14             	add    $0x14,%eax
801027da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e0:	8b 00                	mov    (%eax),%eax
801027e2:	85 c0                	test   %eax,%eax
801027e4:	75 ec                	jne    801027d2 <iderw+0x75>
    ;
  *pp = b;
801027e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027e9:	8b 55 08             	mov    0x8(%ebp),%edx
801027ec:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801027ee:	a1 54 b6 10 80       	mov    0x8010b654,%eax
801027f3:	3b 45 08             	cmp    0x8(%ebp),%eax
801027f6:	75 22                	jne    8010281a <iderw+0xbd>
    idestart(b);
801027f8:	8b 45 08             	mov    0x8(%ebp),%eax
801027fb:	89 04 24             	mov    %eax,(%esp)
801027fe:	e8 72 fd ff ff       	call   80102575 <idestart>
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102803:	eb 15                	jmp    8010281a <iderw+0xbd>
    sleep(b, &idelock);
80102805:	c7 44 24 04 20 b6 10 	movl   $0x8010b620,0x4(%esp)
8010280c:	80 
8010280d:	8b 45 08             	mov    0x8(%ebp),%eax
80102810:	89 04 24             	mov    %eax,(%esp)
80102813:	e8 eb 1f 00 00       	call   80104803 <sleep>
80102818:	eb 01                	jmp    8010281b <iderw+0xbe>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010281a:	90                   	nop
8010281b:	8b 45 08             	mov    0x8(%ebp),%eax
8010281e:	8b 00                	mov    (%eax),%eax
80102820:	83 e0 06             	and    $0x6,%eax
80102823:	83 f8 02             	cmp    $0x2,%eax
80102826:	75 dd                	jne    80102805 <iderw+0xa8>
    sleep(b, &idelock);
  }

  release(&idelock);
80102828:	c7 04 24 20 b6 10 80 	movl   $0x8010b620,(%esp)
8010282f:	e8 59 23 00 00       	call   80104b8d <release>
}
80102834:	c9                   	leave  
80102835:	c3                   	ret    
80102836:	66 90                	xchg   %ax,%ax

80102838 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102838:	55                   	push   %ebp
80102839:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010283b:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102840:	8b 55 08             	mov    0x8(%ebp),%edx
80102843:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102845:	a1 54 f8 10 80       	mov    0x8010f854,%eax
8010284a:	8b 40 10             	mov    0x10(%eax),%eax
}
8010284d:	5d                   	pop    %ebp
8010284e:	c3                   	ret    

8010284f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010284f:	55                   	push   %ebp
80102850:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102852:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102857:	8b 55 08             	mov    0x8(%ebp),%edx
8010285a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010285c:	a1 54 f8 10 80       	mov    0x8010f854,%eax
80102861:	8b 55 0c             	mov    0xc(%ebp),%edx
80102864:	89 50 10             	mov    %edx,0x10(%eax)
}
80102867:	5d                   	pop    %ebp
80102868:	c3                   	ret    

80102869 <ioapicinit>:

void
ioapicinit(void)
{
80102869:	55                   	push   %ebp
8010286a:	89 e5                	mov    %esp,%ebp
8010286c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  if(!ismp)
8010286f:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102874:	85 c0                	test   %eax,%eax
80102876:	0f 84 9a 00 00 00    	je     80102916 <ioapicinit+0xad>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
8010287c:	c7 05 54 f8 10 80 00 	movl   $0xfec00000,0x8010f854
80102883:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102886:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010288d:	e8 a6 ff ff ff       	call   80102838 <ioapicread>
80102892:	c1 e8 10             	shr    $0x10,%eax
80102895:	25 ff 00 00 00       	and    $0xff,%eax
8010289a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
8010289d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028a4:	e8 8f ff ff ff       	call   80102838 <ioapicread>
801028a9:	c1 e8 18             	shr    $0x18,%eax
801028ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801028af:	a0 20 f9 10 80       	mov    0x8010f920,%al
801028b4:	0f b6 c0             	movzbl %al,%eax
801028b7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801028ba:	74 0c                	je     801028c8 <ioapicinit+0x5f>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801028bc:	c7 04 24 54 83 10 80 	movl   $0x80108354,(%esp)
801028c3:	e8 d9 da ff ff       	call   801003a1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801028c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801028cf:	eb 3b                	jmp    8010290c <ioapicinit+0xa3>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801028d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d4:	83 c0 20             	add    $0x20,%eax
801028d7:	0d 00 00 01 00       	or     $0x10000,%eax
801028dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801028df:	83 c2 08             	add    $0x8,%edx
801028e2:	d1 e2                	shl    %edx
801028e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801028e8:	89 14 24             	mov    %edx,(%esp)
801028eb:	e8 5f ff ff ff       	call   8010284f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
801028f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f3:	83 c0 08             	add    $0x8,%eax
801028f6:	d1 e0                	shl    %eax
801028f8:	40                   	inc    %eax
801028f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102900:	00 
80102901:	89 04 24             	mov    %eax,(%esp)
80102904:	e8 46 ff ff ff       	call   8010284f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102909:	ff 45 f4             	incl   -0xc(%ebp)
8010290c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102912:	7e bd                	jle    801028d1 <ioapicinit+0x68>
80102914:	eb 01                	jmp    80102917 <ioapicinit+0xae>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102916:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102917:	c9                   	leave  
80102918:	c3                   	ret    

80102919 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102919:	55                   	push   %ebp
8010291a:	89 e5                	mov    %esp,%ebp
8010291c:	83 ec 08             	sub    $0x8,%esp
  if(!ismp)
8010291f:	a1 24 f9 10 80       	mov    0x8010f924,%eax
80102924:	85 c0                	test   %eax,%eax
80102926:	74 37                	je     8010295f <ioapicenable+0x46>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102928:	8b 45 08             	mov    0x8(%ebp),%eax
8010292b:	83 c0 20             	add    $0x20,%eax
8010292e:	8b 55 08             	mov    0x8(%ebp),%edx
80102931:	83 c2 08             	add    $0x8,%edx
80102934:	d1 e2                	shl    %edx
80102936:	89 44 24 04          	mov    %eax,0x4(%esp)
8010293a:	89 14 24             	mov    %edx,(%esp)
8010293d:	e8 0d ff ff ff       	call   8010284f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102942:	8b 45 0c             	mov    0xc(%ebp),%eax
80102945:	c1 e0 18             	shl    $0x18,%eax
80102948:	8b 55 08             	mov    0x8(%ebp),%edx
8010294b:	83 c2 08             	add    $0x8,%edx
8010294e:	d1 e2                	shl    %edx
80102950:	42                   	inc    %edx
80102951:	89 44 24 04          	mov    %eax,0x4(%esp)
80102955:	89 14 24             	mov    %edx,(%esp)
80102958:	e8 f2 fe ff ff       	call   8010284f <ioapicwrite>
8010295d:	eb 01                	jmp    80102960 <ioapicenable+0x47>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
8010295f:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102960:	c9                   	leave  
80102961:	c3                   	ret    
80102962:	66 90                	xchg   %ax,%ax

80102964 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102964:	55                   	push   %ebp
80102965:	89 e5                	mov    %esp,%ebp
80102967:	8b 45 08             	mov    0x8(%ebp),%eax
8010296a:	05 00 00 00 80       	add    $0x80000000,%eax
8010296f:	5d                   	pop    %ebp
80102970:	c3                   	ret    

80102971 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102971:	55                   	push   %ebp
80102972:	89 e5                	mov    %esp,%ebp
80102974:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102977:	c7 44 24 04 86 83 10 	movl   $0x80108386,0x4(%esp)
8010297e:	80 
8010297f:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102986:	e8 7f 21 00 00       	call   80104b0a <initlock>
  kmem.use_lock = 0;
8010298b:	c7 05 94 f8 10 80 00 	movl   $0x0,0x8010f894
80102992:	00 00 00 
  freerange(vstart, vend);
80102995:	8b 45 0c             	mov    0xc(%ebp),%eax
80102998:	89 44 24 04          	mov    %eax,0x4(%esp)
8010299c:	8b 45 08             	mov    0x8(%ebp),%eax
8010299f:	89 04 24             	mov    %eax,(%esp)
801029a2:	e8 26 00 00 00       	call   801029cd <freerange>
}
801029a7:	c9                   	leave  
801029a8:	c3                   	ret    

801029a9 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801029a9:	55                   	push   %ebp
801029aa:	89 e5                	mov    %esp,%ebp
801029ac:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
801029af:	8b 45 0c             	mov    0xc(%ebp),%eax
801029b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801029b6:	8b 45 08             	mov    0x8(%ebp),%eax
801029b9:	89 04 24             	mov    %eax,(%esp)
801029bc:	e8 0c 00 00 00       	call   801029cd <freerange>
  kmem.use_lock = 1;
801029c1:	c7 05 94 f8 10 80 01 	movl   $0x1,0x8010f894
801029c8:	00 00 00 
}
801029cb:	c9                   	leave  
801029cc:	c3                   	ret    

801029cd <freerange>:

void
freerange(void *vstart, void *vend)
{
801029cd:	55                   	push   %ebp
801029ce:	89 e5                	mov    %esp,%ebp
801029d0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801029d3:	8b 45 08             	mov    0x8(%ebp),%eax
801029d6:	05 ff 0f 00 00       	add    $0xfff,%eax
801029db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801029e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801029e3:	eb 12                	jmp    801029f7 <freerange+0x2a>
    kfree(p);
801029e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e8:	89 04 24             	mov    %eax,(%esp)
801029eb:	e8 16 00 00 00       	call   80102a06 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801029f0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801029f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fa:	05 00 10 00 00       	add    $0x1000,%eax
801029ff:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102a02:	76 e1                	jbe    801029e5 <freerange+0x18>
    kfree(p);
}
80102a04:	c9                   	leave  
80102a05:	c3                   	ret    

80102a06 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102a06:	55                   	push   %ebp
80102a07:	89 e5                	mov    %esp,%ebp
80102a09:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102a0f:	25 ff 0f 00 00       	and    $0xfff,%eax
80102a14:	85 c0                	test   %eax,%eax
80102a16:	75 1b                	jne    80102a33 <kfree+0x2d>
80102a18:	81 7d 08 1c 2b 11 80 	cmpl   $0x80112b1c,0x8(%ebp)
80102a1f:	72 12                	jb     80102a33 <kfree+0x2d>
80102a21:	8b 45 08             	mov    0x8(%ebp),%eax
80102a24:	89 04 24             	mov    %eax,(%esp)
80102a27:	e8 38 ff ff ff       	call   80102964 <v2p>
80102a2c:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102a31:	76 0c                	jbe    80102a3f <kfree+0x39>
    panic("kfree");
80102a33:	c7 04 24 8b 83 10 80 	movl   $0x8010838b,(%esp)
80102a3a:	e8 f7 da ff ff       	call   80100536 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102a3f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102a46:	00 
80102a47:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102a4e:	00 
80102a4f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a52:	89 04 24             	mov    %eax,(%esp)
80102a55:	e8 24 23 00 00       	call   80104d7e <memset>

  if(kmem.use_lock)
80102a5a:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102a5f:	85 c0                	test   %eax,%eax
80102a61:	74 0c                	je     80102a6f <kfree+0x69>
    acquire(&kmem.lock);
80102a63:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102a6a:	e8 bc 20 00 00       	call   80104b2b <acquire>
  r = (struct run*)v;
80102a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102a75:	8b 15 98 f8 10 80    	mov    0x8010f898,%edx
80102a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7e:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a83:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102a88:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102a8d:	85 c0                	test   %eax,%eax
80102a8f:	74 0c                	je     80102a9d <kfree+0x97>
    release(&kmem.lock);
80102a91:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102a98:	e8 f0 20 00 00       	call   80104b8d <release>
}
80102a9d:	c9                   	leave  
80102a9e:	c3                   	ret    

80102a9f <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102a9f:	55                   	push   %ebp
80102aa0:	89 e5                	mov    %esp,%ebp
80102aa2:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102aa5:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102aaa:	85 c0                	test   %eax,%eax
80102aac:	74 0c                	je     80102aba <kalloc+0x1b>
    acquire(&kmem.lock);
80102aae:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102ab5:	e8 71 20 00 00       	call   80104b2b <acquire>
  r = kmem.freelist;
80102aba:	a1 98 f8 10 80       	mov    0x8010f898,%eax
80102abf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ac2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ac6:	74 0a                	je     80102ad2 <kalloc+0x33>
    kmem.freelist = r->next;
80102ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102acb:	8b 00                	mov    (%eax),%eax
80102acd:	a3 98 f8 10 80       	mov    %eax,0x8010f898
  if(kmem.use_lock)
80102ad2:	a1 94 f8 10 80       	mov    0x8010f894,%eax
80102ad7:	85 c0                	test   %eax,%eax
80102ad9:	74 0c                	je     80102ae7 <kalloc+0x48>
    release(&kmem.lock);
80102adb:	c7 04 24 60 f8 10 80 	movl   $0x8010f860,(%esp)
80102ae2:	e8 a6 20 00 00       	call   80104b8d <release>
  return (char*)r;
80102ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102aea:	c9                   	leave  
80102aeb:	c3                   	ret    

80102aec <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102aec:	55                   	push   %ebp
80102aed:	89 e5                	mov    %esp,%ebp
80102aef:	53                   	push   %ebx
80102af0:	83 ec 14             	sub    $0x14,%esp
80102af3:	8b 45 08             	mov    0x8(%ebp),%eax
80102af6:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102afa:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102afd:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
80102b01:	66 8b 55 ea          	mov    -0x16(%ebp),%dx
80102b05:	ec                   	in     (%dx),%al
80102b06:	88 c3                	mov    %al,%bl
80102b08:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
80102b0b:	8a 45 fb             	mov    -0x5(%ebp),%al
}
80102b0e:	83 c4 14             	add    $0x14,%esp
80102b11:	5b                   	pop    %ebx
80102b12:	5d                   	pop    %ebp
80102b13:	c3                   	ret    

80102b14 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
80102b17:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102b1a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102b21:	e8 c6 ff ff ff       	call   80102aec <inb>
80102b26:	0f b6 c0             	movzbl %al,%eax
80102b29:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b2f:	83 e0 01             	and    $0x1,%eax
80102b32:	85 c0                	test   %eax,%eax
80102b34:	75 0a                	jne    80102b40 <kbdgetc+0x2c>
    return -1;
80102b36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102b3b:	e9 21 01 00 00       	jmp    80102c61 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102b40:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102b47:	e8 a0 ff ff ff       	call   80102aec <inb>
80102b4c:	0f b6 c0             	movzbl %al,%eax
80102b4f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102b52:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102b59:	75 17                	jne    80102b72 <kbdgetc+0x5e>
    shift |= E0ESC;
80102b5b:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102b60:	83 c8 40             	or     $0x40,%eax
80102b63:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102b68:	b8 00 00 00 00       	mov    $0x0,%eax
80102b6d:	e9 ef 00 00 00       	jmp    80102c61 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102b72:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102b75:	25 80 00 00 00       	and    $0x80,%eax
80102b7a:	85 c0                	test   %eax,%eax
80102b7c:	74 44                	je     80102bc2 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102b7e:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102b83:	83 e0 40             	and    $0x40,%eax
80102b86:	85 c0                	test   %eax,%eax
80102b88:	75 08                	jne    80102b92 <kbdgetc+0x7e>
80102b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102b8d:	83 e0 7f             	and    $0x7f,%eax
80102b90:	eb 03                	jmp    80102b95 <kbdgetc+0x81>
80102b92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102b95:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102b9b:	05 20 90 10 80       	add    $0x80109020,%eax
80102ba0:	8a 00                	mov    (%eax),%al
80102ba2:	83 c8 40             	or     $0x40,%eax
80102ba5:	0f b6 c0             	movzbl %al,%eax
80102ba8:	f7 d0                	not    %eax
80102baa:	89 c2                	mov    %eax,%edx
80102bac:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102bb1:	21 d0                	and    %edx,%eax
80102bb3:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
    return 0;
80102bb8:	b8 00 00 00 00       	mov    $0x0,%eax
80102bbd:	e9 9f 00 00 00       	jmp    80102c61 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102bc2:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102bc7:	83 e0 40             	and    $0x40,%eax
80102bca:	85 c0                	test   %eax,%eax
80102bcc:	74 14                	je     80102be2 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102bce:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102bd5:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102bda:	83 e0 bf             	and    $0xffffffbf,%eax
80102bdd:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  }

  shift |= shiftcode[data];
80102be2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102be5:	05 20 90 10 80       	add    $0x80109020,%eax
80102bea:	8a 00                	mov    (%eax),%al
80102bec:	0f b6 d0             	movzbl %al,%edx
80102bef:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102bf4:	09 d0                	or     %edx,%eax
80102bf6:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  shift ^= togglecode[data];
80102bfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102bfe:	05 20 91 10 80       	add    $0x80109120,%eax
80102c03:	8a 00                	mov    (%eax),%al
80102c05:	0f b6 d0             	movzbl %al,%edx
80102c08:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c0d:	31 d0                	xor    %edx,%eax
80102c0f:	a3 5c b6 10 80       	mov    %eax,0x8010b65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102c14:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c19:	83 e0 03             	and    $0x3,%eax
80102c1c:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102c23:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c26:	01 d0                	add    %edx,%eax
80102c28:	8a 00                	mov    (%eax),%al
80102c2a:	0f b6 c0             	movzbl %al,%eax
80102c2d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102c30:	a1 5c b6 10 80       	mov    0x8010b65c,%eax
80102c35:	83 e0 08             	and    $0x8,%eax
80102c38:	85 c0                	test   %eax,%eax
80102c3a:	74 22                	je     80102c5e <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102c3c:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102c40:	76 0c                	jbe    80102c4e <kbdgetc+0x13a>
80102c42:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102c46:	77 06                	ja     80102c4e <kbdgetc+0x13a>
      c += 'A' - 'a';
80102c48:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102c4c:	eb 10                	jmp    80102c5e <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102c4e:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102c52:	76 0a                	jbe    80102c5e <kbdgetc+0x14a>
80102c54:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102c58:	77 04                	ja     80102c5e <kbdgetc+0x14a>
      c += 'a' - 'A';
80102c5a:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102c5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102c61:	c9                   	leave  
80102c62:	c3                   	ret    

80102c63 <kbdintr>:

void
kbdintr(void)
{
80102c63:	55                   	push   %ebp
80102c64:	89 e5                	mov    %esp,%ebp
80102c66:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102c69:	c7 04 24 14 2b 10 80 	movl   $0x80102b14,(%esp)
80102c70:	e8 1b db ff ff       	call   80100790 <consoleintr>
}
80102c75:	c9                   	leave  
80102c76:	c3                   	ret    
80102c77:	90                   	nop

80102c78 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102c78:	55                   	push   %ebp
80102c79:	89 e5                	mov    %esp,%ebp
80102c7b:	83 ec 08             	sub    $0x8,%esp
80102c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80102c81:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c84:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102c88:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c8b:	8a 45 f8             	mov    -0x8(%ebp),%al
80102c8e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102c91:	ee                   	out    %al,(%dx)
}
80102c92:	c9                   	leave  
80102c93:	c3                   	ret    

80102c94 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102c94:	55                   	push   %ebp
80102c95:	89 e5                	mov    %esp,%ebp
80102c97:	53                   	push   %ebx
80102c98:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102c9b:	9c                   	pushf  
80102c9c:	5b                   	pop    %ebx
80102c9d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80102ca0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ca3:	83 c4 10             	add    $0x10,%esp
80102ca6:	5b                   	pop    %ebx
80102ca7:	5d                   	pop    %ebp
80102ca8:	c3                   	ret    

80102ca9 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102ca9:	55                   	push   %ebp
80102caa:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102cac:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102cb1:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb4:	c1 e2 02             	shl    $0x2,%edx
80102cb7:	01 c2                	add    %eax,%edx
80102cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cbc:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102cbe:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102cc3:	83 c0 20             	add    $0x20,%eax
80102cc6:	8b 00                	mov    (%eax),%eax
}
80102cc8:	5d                   	pop    %ebp
80102cc9:	c3                   	ret    

80102cca <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102cca:	55                   	push   %ebp
80102ccb:	89 e5                	mov    %esp,%ebp
80102ccd:	83 ec 08             	sub    $0x8,%esp
  if(!lapic) 
80102cd0:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102cd5:	85 c0                	test   %eax,%eax
80102cd7:	0f 84 47 01 00 00    	je     80102e24 <lapicinit+0x15a>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102cdd:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102ce4:	00 
80102ce5:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102cec:	e8 b8 ff ff ff       	call   80102ca9 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102cf1:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102cf8:	00 
80102cf9:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102d00:	e8 a4 ff ff ff       	call   80102ca9 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102d05:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102d0c:	00 
80102d0d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102d14:	e8 90 ff ff ff       	call   80102ca9 <lapicw>
  lapicw(TICR, 10000000); 
80102d19:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102d20:	00 
80102d21:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102d28:	e8 7c ff ff ff       	call   80102ca9 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102d2d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d34:	00 
80102d35:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102d3c:	e8 68 ff ff ff       	call   80102ca9 <lapicw>
  lapicw(LINT1, MASKED);
80102d41:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d48:	00 
80102d49:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102d50:	e8 54 ff ff ff       	call   80102ca9 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102d55:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102d5a:	83 c0 30             	add    $0x30,%eax
80102d5d:	8b 00                	mov    (%eax),%eax
80102d5f:	c1 e8 10             	shr    $0x10,%eax
80102d62:	25 ff 00 00 00       	and    $0xff,%eax
80102d67:	83 f8 03             	cmp    $0x3,%eax
80102d6a:	76 14                	jbe    80102d80 <lapicinit+0xb6>
    lapicw(PCINT, MASKED);
80102d6c:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102d73:	00 
80102d74:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102d7b:	e8 29 ff ff ff       	call   80102ca9 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102d80:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102d87:	00 
80102d88:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102d8f:	e8 15 ff ff ff       	call   80102ca9 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102d94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102d9b:	00 
80102d9c:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102da3:	e8 01 ff ff ff       	call   80102ca9 <lapicw>
  lapicw(ESR, 0);
80102da8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102daf:	00 
80102db0:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102db7:	e8 ed fe ff ff       	call   80102ca9 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102dbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dc3:	00 
80102dc4:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102dcb:	e8 d9 fe ff ff       	call   80102ca9 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102dd0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102dd7:	00 
80102dd8:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102ddf:	e8 c5 fe ff ff       	call   80102ca9 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102de4:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102deb:	00 
80102dec:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102df3:	e8 b1 fe ff ff       	call   80102ca9 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102df8:	90                   	nop
80102df9:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102dfe:	05 00 03 00 00       	add    $0x300,%eax
80102e03:	8b 00                	mov    (%eax),%eax
80102e05:	25 00 10 00 00       	and    $0x1000,%eax
80102e0a:	85 c0                	test   %eax,%eax
80102e0c:	75 eb                	jne    80102df9 <lapicinit+0x12f>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102e0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e15:	00 
80102e16:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102e1d:	e8 87 fe ff ff       	call   80102ca9 <lapicw>
80102e22:	eb 01                	jmp    80102e25 <lapicinit+0x15b>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102e24:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102e25:	c9                   	leave  
80102e26:	c3                   	ret    

80102e27 <cpunum>:

int
cpunum(void)
{
80102e27:	55                   	push   %ebp
80102e28:	89 e5                	mov    %esp,%ebp
80102e2a:	83 ec 18             	sub    $0x18,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102e2d:	e8 62 fe ff ff       	call   80102c94 <readeflags>
80102e32:	25 00 02 00 00       	and    $0x200,%eax
80102e37:	85 c0                	test   %eax,%eax
80102e39:	74 27                	je     80102e62 <cpunum+0x3b>
    static int n;
    if(n++ == 0)
80102e3b:	a1 60 b6 10 80       	mov    0x8010b660,%eax
80102e40:	85 c0                	test   %eax,%eax
80102e42:	0f 94 c2             	sete   %dl
80102e45:	40                   	inc    %eax
80102e46:	a3 60 b6 10 80       	mov    %eax,0x8010b660
80102e4b:	84 d2                	test   %dl,%dl
80102e4d:	74 13                	je     80102e62 <cpunum+0x3b>
      cprintf("cpu called from %x with interrupts enabled\n",
80102e4f:	8b 45 04             	mov    0x4(%ebp),%eax
80102e52:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e56:	c7 04 24 94 83 10 80 	movl   $0x80108394,(%esp)
80102e5d:	e8 3f d5 ff ff       	call   801003a1 <cprintf>
        __builtin_return_address(0));
  }

  if(lapic)
80102e62:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e67:	85 c0                	test   %eax,%eax
80102e69:	74 0f                	je     80102e7a <cpunum+0x53>
    return lapic[ID]>>24;
80102e6b:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e70:	83 c0 20             	add    $0x20,%eax
80102e73:	8b 00                	mov    (%eax),%eax
80102e75:	c1 e8 18             	shr    $0x18,%eax
80102e78:	eb 05                	jmp    80102e7f <cpunum+0x58>
  return 0;
80102e7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e7f:	c9                   	leave  
80102e80:	c3                   	ret    

80102e81 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102e81:	55                   	push   %ebp
80102e82:	89 e5                	mov    %esp,%ebp
80102e84:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102e87:	a1 9c f8 10 80       	mov    0x8010f89c,%eax
80102e8c:	85 c0                	test   %eax,%eax
80102e8e:	74 14                	je     80102ea4 <lapiceoi+0x23>
    lapicw(EOI, 0);
80102e90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102e97:	00 
80102e98:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102e9f:	e8 05 fe ff ff       	call   80102ca9 <lapicw>
}
80102ea4:	c9                   	leave  
80102ea5:	c3                   	ret    

80102ea6 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102ea6:	55                   	push   %ebp
80102ea7:	89 e5                	mov    %esp,%ebp
}
80102ea9:	5d                   	pop    %ebp
80102eaa:	c3                   	ret    

80102eab <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102eab:	55                   	push   %ebp
80102eac:	89 e5                	mov    %esp,%ebp
80102eae:	83 ec 1c             	sub    $0x1c,%esp
80102eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80102eb4:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
80102eb7:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80102ebe:	00 
80102ebf:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80102ec6:	e8 ad fd ff ff       	call   80102c78 <outb>
  outb(IO_RTC+1, 0x0A);
80102ecb:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80102ed2:	00 
80102ed3:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80102eda:	e8 99 fd ff ff       	call   80102c78 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102edf:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102ee6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ee9:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102eee:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102ef1:	8d 50 02             	lea    0x2(%eax),%edx
80102ef4:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ef7:	c1 e8 04             	shr    $0x4,%eax
80102efa:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102efd:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f01:	c1 e0 18             	shl    $0x18,%eax
80102f04:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f08:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f0f:	e8 95 fd ff ff       	call   80102ca9 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102f14:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80102f1b:	00 
80102f1c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f23:	e8 81 fd ff ff       	call   80102ca9 <lapicw>
  microdelay(200);
80102f28:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f2f:	e8 72 ff ff ff       	call   80102ea6 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80102f34:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80102f3b:	00 
80102f3c:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f43:	e8 61 fd ff ff       	call   80102ca9 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102f48:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102f4f:	e8 52 ff ff ff       	call   80102ea6 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102f54:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102f5b:	eb 3f                	jmp    80102f9c <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80102f5d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102f61:	c1 e0 18             	shl    $0x18,%eax
80102f64:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f68:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f6f:	e8 35 fd ff ff       	call   80102ca9 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102f74:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f77:	c1 e8 0c             	shr    $0xc,%eax
80102f7a:	80 cc 06             	or     $0x6,%ah
80102f7d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f81:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102f88:	e8 1c fd ff ff       	call   80102ca9 <lapicw>
    microdelay(200);
80102f8d:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f94:	e8 0d ff ff ff       	call   80102ea6 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102f99:	ff 45 fc             	incl   -0x4(%ebp)
80102f9c:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102fa0:	7e bb                	jle    80102f5d <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80102fa2:	c9                   	leave  
80102fa3:	c3                   	ret    

80102fa4 <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
80102fa4:	55                   	push   %ebp
80102fa5:	89 e5                	mov    %esp,%ebp
80102fa7:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102faa:	c7 44 24 04 c0 83 10 	movl   $0x801083c0,0x4(%esp)
80102fb1:	80 
80102fb2:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80102fb9:	e8 4c 1b 00 00       	call   80104b0a <initlock>
  readsb(ROOTDEV, &sb);
80102fbe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80102fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fc5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102fcc:	e8 e3 e2 ff ff       	call   801012b4 <readsb>
  log.start = sb.size - sb.nlog;
80102fd1:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fd7:	89 d1                	mov    %edx,%ecx
80102fd9:	29 c1                	sub    %eax,%ecx
80102fdb:	89 c8                	mov    %ecx,%eax
80102fdd:	a3 d4 f8 10 80       	mov    %eax,0x8010f8d4
  log.size = sb.nlog;
80102fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fe5:	a3 d8 f8 10 80       	mov    %eax,0x8010f8d8
  log.dev = ROOTDEV;
80102fea:	c7 05 e0 f8 10 80 01 	movl   $0x1,0x8010f8e0
80102ff1:	00 00 00 
  recover_from_log();
80102ff4:	e8 95 01 00 00       	call   8010318e <recover_from_log>
}
80102ff9:	c9                   	leave  
80102ffa:	c3                   	ret    

80102ffb <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80102ffb:	55                   	push   %ebp
80102ffc:	89 e5                	mov    %esp,%ebp
80102ffe:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103001:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103008:	e9 89 00 00 00       	jmp    80103096 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010300d:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
80103013:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103016:	01 d0                	add    %edx,%eax
80103018:	40                   	inc    %eax
80103019:	89 c2                	mov    %eax,%edx
8010301b:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103020:	89 54 24 04          	mov    %edx,0x4(%esp)
80103024:	89 04 24             	mov    %eax,(%esp)
80103027:	e8 7a d1 ff ff       	call   801001a6 <bread>
8010302c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010302f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103032:	83 c0 10             	add    $0x10,%eax
80103035:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
8010303c:	89 c2                	mov    %eax,%edx
8010303e:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103043:	89 54 24 04          	mov    %edx,0x4(%esp)
80103047:	89 04 24             	mov    %eax,(%esp)
8010304a:	e8 57 d1 ff ff       	call   801001a6 <bread>
8010304f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103052:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103055:	8d 50 18             	lea    0x18(%eax),%edx
80103058:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010305b:	83 c0 18             	add    $0x18,%eax
8010305e:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103065:	00 
80103066:	89 54 24 04          	mov    %edx,0x4(%esp)
8010306a:	89 04 24             	mov    %eax,(%esp)
8010306d:	e8 d8 1d 00 00       	call   80104e4a <memmove>
    bwrite(dbuf);  // write dst to disk
80103072:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103075:	89 04 24             	mov    %eax,(%esp)
80103078:	e8 60 d1 ff ff       	call   801001dd <bwrite>
    brelse(lbuf); 
8010307d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103080:	89 04 24             	mov    %eax,(%esp)
80103083:	e8 8f d1 ff ff       	call   80100217 <brelse>
    brelse(dbuf);
80103088:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010308b:	89 04 24             	mov    %eax,(%esp)
8010308e:	e8 84 d1 ff ff       	call   80100217 <brelse>
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103093:	ff 45 f4             	incl   -0xc(%ebp)
80103096:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010309b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010309e:	0f 8f 69 ff ff ff    	jg     8010300d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801030a4:	c9                   	leave  
801030a5:	c3                   	ret    

801030a6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801030a6:	55                   	push   %ebp
801030a7:	89 e5                	mov    %esp,%ebp
801030a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801030ac:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
801030b1:	89 c2                	mov    %eax,%edx
801030b3:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
801030b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801030bc:	89 04 24             	mov    %eax,(%esp)
801030bf:	e8 e2 d0 ff ff       	call   801001a6 <bread>
801030c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801030c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801030ca:	83 c0 18             	add    $0x18,%eax
801030cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801030d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030d3:	8b 00                	mov    (%eax),%eax
801030d5:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  for (i = 0; i < log.lh.n; i++) {
801030da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801030e1:	eb 1a                	jmp    801030fd <read_head+0x57>
    log.lh.sector[i] = lh->sector[i];
801030e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801030e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030e9:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801030ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
801030f0:	83 c2 10             	add    $0x10,%edx
801030f3:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801030fa:	ff 45 f4             	incl   -0xc(%ebp)
801030fd:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103102:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103105:	7f dc                	jg     801030e3 <read_head+0x3d>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
80103107:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010310a:	89 04 24             	mov    %eax,(%esp)
8010310d:	e8 05 d1 ff ff       	call   80100217 <brelse>
}
80103112:	c9                   	leave  
80103113:	c3                   	ret    

80103114 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103114:	55                   	push   %ebp
80103115:	89 e5                	mov    %esp,%ebp
80103117:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010311a:	a1 d4 f8 10 80       	mov    0x8010f8d4,%eax
8010311f:	89 c2                	mov    %eax,%edx
80103121:	a1 e0 f8 10 80       	mov    0x8010f8e0,%eax
80103126:	89 54 24 04          	mov    %edx,0x4(%esp)
8010312a:	89 04 24             	mov    %eax,(%esp)
8010312d:	e8 74 d0 ff ff       	call   801001a6 <bread>
80103132:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103135:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103138:	83 c0 18             	add    $0x18,%eax
8010313b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010313e:	8b 15 e4 f8 10 80    	mov    0x8010f8e4,%edx
80103144:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103147:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103149:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103150:	eb 1a                	jmp    8010316c <write_head+0x58>
    hb->sector[i] = log.lh.sector[i];
80103152:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103155:	83 c0 10             	add    $0x10,%eax
80103158:	8b 0c 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%ecx
8010315f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103162:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103165:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103169:	ff 45 f4             	incl   -0xc(%ebp)
8010316c:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103171:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103174:	7f dc                	jg     80103152 <write_head+0x3e>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103176:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103179:	89 04 24             	mov    %eax,(%esp)
8010317c:	e8 5c d0 ff ff       	call   801001dd <bwrite>
  brelse(buf);
80103181:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103184:	89 04 24             	mov    %eax,(%esp)
80103187:	e8 8b d0 ff ff       	call   80100217 <brelse>
}
8010318c:	c9                   	leave  
8010318d:	c3                   	ret    

8010318e <recover_from_log>:

static void
recover_from_log(void)
{
8010318e:	55                   	push   %ebp
8010318f:	89 e5                	mov    %esp,%ebp
80103191:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103194:	e8 0d ff ff ff       	call   801030a6 <read_head>
  install_trans(); // if committed, copy from log to disk
80103199:	e8 5d fe ff ff       	call   80102ffb <install_trans>
  log.lh.n = 0;
8010319e:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
801031a5:	00 00 00 
  write_head(); // clear the log
801031a8:	e8 67 ff ff ff       	call   80103114 <write_head>
}
801031ad:	c9                   	leave  
801031ae:	c3                   	ret    

801031af <begin_trans>:

void
begin_trans(void)
{
801031af:	55                   	push   %ebp
801031b0:	89 e5                	mov    %esp,%ebp
801031b2:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801031b5:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801031bc:	e8 6a 19 00 00       	call   80104b2b <acquire>
  while (log.busy) {
801031c1:	eb 14                	jmp    801031d7 <begin_trans+0x28>
    sleep(&log, &log.lock);
801031c3:	c7 44 24 04 a0 f8 10 	movl   $0x8010f8a0,0x4(%esp)
801031ca:	80 
801031cb:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801031d2:	e8 2c 16 00 00       	call   80104803 <sleep>

void
begin_trans(void)
{
  acquire(&log.lock);
  while (log.busy) {
801031d7:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
801031dc:	85 c0                	test   %eax,%eax
801031de:	75 e3                	jne    801031c3 <begin_trans+0x14>
    sleep(&log, &log.lock);
  }
  log.busy = 1;
801031e0:	c7 05 dc f8 10 80 01 	movl   $0x1,0x8010f8dc
801031e7:	00 00 00 
  release(&log.lock);
801031ea:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
801031f1:	e8 97 19 00 00       	call   80104b8d <release>
}
801031f6:	c9                   	leave  
801031f7:	c3                   	ret    

801031f8 <commit_trans>:

void
commit_trans(void)
{
801031f8:	55                   	push   %ebp
801031f9:	89 e5                	mov    %esp,%ebp
801031fb:	83 ec 18             	sub    $0x18,%esp
  if (log.lh.n > 0) {
801031fe:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103203:	85 c0                	test   %eax,%eax
80103205:	7e 19                	jle    80103220 <commit_trans+0x28>
    write_head();    // Write header to disk -- the real commit
80103207:	e8 08 ff ff ff       	call   80103114 <write_head>
    install_trans(); // Now install writes to home locations
8010320c:	e8 ea fd ff ff       	call   80102ffb <install_trans>
    log.lh.n = 0; 
80103211:	c7 05 e4 f8 10 80 00 	movl   $0x0,0x8010f8e4
80103218:	00 00 00 
    write_head();    // Erase the transaction from the log
8010321b:	e8 f4 fe ff ff       	call   80103114 <write_head>
  }
  
  acquire(&log.lock);
80103220:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103227:	e8 ff 18 00 00       	call   80104b2b <acquire>
  log.busy = 0;
8010322c:	c7 05 dc f8 10 80 00 	movl   $0x0,0x8010f8dc
80103233:	00 00 00 
  wakeup(&log);
80103236:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
8010323d:	e8 9d 16 00 00       	call   801048df <wakeup>
  release(&log.lock);
80103242:	c7 04 24 a0 f8 10 80 	movl   $0x8010f8a0,(%esp)
80103249:	e8 3f 19 00 00       	call   80104b8d <release>
}
8010324e:	c9                   	leave  
8010324f:	c3                   	ret    

80103250 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103250:	55                   	push   %ebp
80103251:	89 e5                	mov    %esp,%ebp
80103253:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103256:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010325b:	83 f8 09             	cmp    $0x9,%eax
8010325e:	7f 10                	jg     80103270 <log_write+0x20>
80103260:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103265:	8b 15 d8 f8 10 80    	mov    0x8010f8d8,%edx
8010326b:	4a                   	dec    %edx
8010326c:	39 d0                	cmp    %edx,%eax
8010326e:	7c 0c                	jl     8010327c <log_write+0x2c>
    panic("too big a transaction");
80103270:	c7 04 24 c4 83 10 80 	movl   $0x801083c4,(%esp)
80103277:	e8 ba d2 ff ff       	call   80100536 <panic>
  if (!log.busy)
8010327c:	a1 dc f8 10 80       	mov    0x8010f8dc,%eax
80103281:	85 c0                	test   %eax,%eax
80103283:	75 0c                	jne    80103291 <log_write+0x41>
    panic("write outside of trans");
80103285:	c7 04 24 da 83 10 80 	movl   $0x801083da,(%esp)
8010328c:	e8 a5 d2 ff ff       	call   80100536 <panic>

  for (i = 0; i < log.lh.n; i++) {
80103291:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103298:	eb 1c                	jmp    801032b6 <log_write+0x66>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
8010329a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010329d:	83 c0 10             	add    $0x10,%eax
801032a0:	8b 04 85 a8 f8 10 80 	mov    -0x7fef0758(,%eax,4),%eax
801032a7:	89 c2                	mov    %eax,%edx
801032a9:	8b 45 08             	mov    0x8(%ebp),%eax
801032ac:	8b 40 08             	mov    0x8(%eax),%eax
801032af:	39 c2                	cmp    %eax,%edx
801032b1:	74 0f                	je     801032c2 <log_write+0x72>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if (!log.busy)
    panic("write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
801032b3:	ff 45 f4             	incl   -0xc(%ebp)
801032b6:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
801032bb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801032be:	7f da                	jg     8010329a <log_write+0x4a>
801032c0:	eb 01                	jmp    801032c3 <log_write+0x73>
    if (log.lh.sector[i] == b->sector)   // log absorbtion?
      break;
801032c2:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
801032c3:	8b 45 08             	mov    0x8(%ebp),%eax
801032c6:	8b 40 08             	mov    0x8(%eax),%eax
801032c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801032cc:	83 c2 10             	add    $0x10,%edx
801032cf:	89 04 95 a8 f8 10 80 	mov    %eax,-0x7fef0758(,%edx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
801032d6:	8b 15 d4 f8 10 80    	mov    0x8010f8d4,%edx
801032dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032df:	01 d0                	add    %edx,%eax
801032e1:	40                   	inc    %eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 08             	mov    0x8(%ebp),%eax
801032e7:	8b 40 04             	mov    0x4(%eax),%eax
801032ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801032ee:	89 04 24             	mov    %eax,(%esp)
801032f1:	e8 b0 ce ff ff       	call   801001a6 <bread>
801032f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(lbuf->data, b->data, BSIZE);
801032f9:	8b 45 08             	mov    0x8(%ebp),%eax
801032fc:	8d 50 18             	lea    0x18(%eax),%edx
801032ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103302:	83 c0 18             	add    $0x18,%eax
80103305:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010330c:	00 
8010330d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103311:	89 04 24             	mov    %eax,(%esp)
80103314:	e8 31 1b 00 00       	call   80104e4a <memmove>
  bwrite(lbuf);
80103319:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010331c:	89 04 24             	mov    %eax,(%esp)
8010331f:	e8 b9 ce ff ff       	call   801001dd <bwrite>
  brelse(lbuf);
80103324:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103327:	89 04 24             	mov    %eax,(%esp)
8010332a:	e8 e8 ce ff ff       	call   80100217 <brelse>
  if (i == log.lh.n)
8010332f:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
80103334:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103337:	75 0b                	jne    80103344 <log_write+0xf4>
    log.lh.n++;
80103339:	a1 e4 f8 10 80       	mov    0x8010f8e4,%eax
8010333e:	40                   	inc    %eax
8010333f:	a3 e4 f8 10 80       	mov    %eax,0x8010f8e4
  b->flags |= B_DIRTY; // XXX prevent eviction
80103344:	8b 45 08             	mov    0x8(%ebp),%eax
80103347:	8b 00                	mov    (%eax),%eax
80103349:	89 c2                	mov    %eax,%edx
8010334b:	83 ca 04             	or     $0x4,%edx
8010334e:	8b 45 08             	mov    0x8(%ebp),%eax
80103351:	89 10                	mov    %edx,(%eax)
}
80103353:	c9                   	leave  
80103354:	c3                   	ret    
80103355:	66 90                	xchg   %ax,%ax
80103357:	90                   	nop

80103358 <v2p>:
80103358:	55                   	push   %ebp
80103359:	89 e5                	mov    %esp,%ebp
8010335b:	8b 45 08             	mov    0x8(%ebp),%eax
8010335e:	05 00 00 00 80       	add    $0x80000000,%eax
80103363:	5d                   	pop    %ebp
80103364:	c3                   	ret    

80103365 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103365:	55                   	push   %ebp
80103366:	89 e5                	mov    %esp,%ebp
80103368:	8b 45 08             	mov    0x8(%ebp),%eax
8010336b:	05 00 00 00 80       	add    $0x80000000,%eax
80103370:	5d                   	pop    %ebp
80103371:	c3                   	ret    

80103372 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103372:	55                   	push   %ebp
80103373:	89 e5                	mov    %esp,%ebp
80103375:	53                   	push   %ebx
80103376:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80103379:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010337c:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
8010337f:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103382:	89 c3                	mov    %eax,%ebx
80103384:	89 d8                	mov    %ebx,%eax
80103386:	f0 87 02             	lock xchg %eax,(%edx)
80103389:	89 c3                	mov    %eax,%ebx
8010338b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010338e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103391:	83 c4 10             	add    $0x10,%esp
80103394:	5b                   	pop    %ebx
80103395:	5d                   	pop    %ebp
80103396:	c3                   	ret    

80103397 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103397:	55                   	push   %ebp
80103398:	89 e5                	mov    %esp,%ebp
8010339a:	83 e4 f0             	and    $0xfffffff0,%esp
8010339d:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801033a0:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801033a7:	80 
801033a8:	c7 04 24 1c 2b 11 80 	movl   $0x80112b1c,(%esp)
801033af:	e8 bd f5 ff ff       	call   80102971 <kinit1>
  kvmalloc();      // kernel page table
801033b4:	e8 54 46 00 00       	call   80107a0d <kvmalloc>
  mpinit();        // collect info about this machine
801033b9:	e8 93 04 00 00       	call   80103851 <mpinit>
  lapicinit();
801033be:	e8 07 f9 ff ff       	call   80102cca <lapicinit>
  seginit();       // set up segments
801033c3:	e8 01 40 00 00       	call   801073c9 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801033c8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801033ce:	8a 00                	mov    (%eax),%al
801033d0:	0f b6 c0             	movzbl %al,%eax
801033d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801033d7:	c7 04 24 f1 83 10 80 	movl   $0x801083f1,(%esp)
801033de:	e8 be cf ff ff       	call   801003a1 <cprintf>
  picinit();       // interrupt controller
801033e3:	e8 d0 06 00 00       	call   80103ab8 <picinit>
  ioapicinit();    // another interrupt controller
801033e8:	e8 7c f4 ff ff       	call   80102869 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801033ed:	e8 6b d6 ff ff       	call   80100a5d <consoleinit>
  uartinit();      // serial port
801033f2:	e8 25 33 00 00       	call   8010671c <uartinit>
  pinit();         // process table
801033f7:	e8 cf 0b 00 00       	call   80103fcb <pinit>
  tvinit();        // trap vectors
801033fc:	e8 8c 2e 00 00       	call   8010628d <tvinit>
  binit();         // buffer cache
80103401:	e8 2e cc ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103406:	e8 cd da ff ff       	call   80100ed8 <fileinit>
  iinit();         // inode cache
8010340b:	e8 60 e1 ff ff       	call   80101570 <iinit>
  ideinit();       // disk
80103410:	e8 bd f0 ff ff       	call   801024d2 <ideinit>
  if(!ismp)
80103415:	a1 24 f9 10 80       	mov    0x8010f924,%eax
8010341a:	85 c0                	test   %eax,%eax
8010341c:	75 05                	jne    80103423 <main+0x8c>
    timerinit();   // uniprocessor timer
8010341e:	e8 b1 2d 00 00       	call   801061d4 <timerinit>
  startothers();   // start other processors
80103423:	e8 7e 00 00 00       	call   801034a6 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103428:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010342f:	8e 
80103430:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103437:	e8 6d f5 ff ff       	call   801029a9 <kinit2>
  userinit();      // first user process
8010343c:	e8 c5 0c 00 00       	call   80104106 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103441:	e8 1a 00 00 00       	call   80103460 <mpmain>

80103446 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103446:	55                   	push   %ebp
80103447:	89 e5                	mov    %esp,%ebp
80103449:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010344c:	e8 d3 45 00 00       	call   80107a24 <switchkvm>
  seginit();
80103451:	e8 73 3f 00 00       	call   801073c9 <seginit>
  lapicinit();
80103456:	e8 6f f8 ff ff       	call   80102cca <lapicinit>
  mpmain();
8010345b:	e8 00 00 00 00       	call   80103460 <mpmain>

80103460 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103460:	55                   	push   %ebp
80103461:	89 e5                	mov    %esp,%ebp
80103463:	83 ec 18             	sub    $0x18,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103466:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010346c:	8a 00                	mov    (%eax),%al
8010346e:	0f b6 c0             	movzbl %al,%eax
80103471:	89 44 24 04          	mov    %eax,0x4(%esp)
80103475:	c7 04 24 08 84 10 80 	movl   $0x80108408,(%esp)
8010347c:	e8 20 cf ff ff       	call   801003a1 <cprintf>
  idtinit();       // load idt register
80103481:	e8 64 2f 00 00       	call   801063ea <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103486:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010348c:	05 a8 00 00 00       	add    $0xa8,%eax
80103491:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103498:	00 
80103499:	89 04 24             	mov    %eax,(%esp)
8010349c:	e8 d1 fe ff ff       	call   80103372 <xchg>
  scheduler();     // start running processes
801034a1:	e8 b1 11 00 00       	call   80104657 <scheduler>

801034a6 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801034a6:	55                   	push   %ebp
801034a7:	89 e5                	mov    %esp,%ebp
801034a9:	53                   	push   %ebx
801034aa:	83 ec 24             	sub    $0x24,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801034ad:	c7 04 24 00 70 00 00 	movl   $0x7000,(%esp)
801034b4:	e8 ac fe ff ff       	call   80103365 <p2v>
801034b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801034bc:	b8 8a 00 00 00       	mov    $0x8a,%eax
801034c1:	89 44 24 08          	mov    %eax,0x8(%esp)
801034c5:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
801034cc:	80 
801034cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d0:	89 04 24             	mov    %eax,(%esp)
801034d3:	e8 72 19 00 00       	call   80104e4a <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801034d8:	c7 45 f4 40 f9 10 80 	movl   $0x8010f940,-0xc(%ebp)
801034df:	e9 8f 00 00 00       	jmp    80103573 <startothers+0xcd>
    if(c == cpus+cpunum())  // We've started already.
801034e4:	e8 3e f9 ff ff       	call   80102e27 <cpunum>
801034e9:	89 c2                	mov    %eax,%edx
801034eb:	89 d0                	mov    %edx,%eax
801034ed:	d1 e0                	shl    %eax
801034ef:	01 d0                	add    %edx,%eax
801034f1:	c1 e0 04             	shl    $0x4,%eax
801034f4:	29 d0                	sub    %edx,%eax
801034f6:	c1 e0 02             	shl    $0x2,%eax
801034f9:	05 40 f9 10 80       	add    $0x8010f940,%eax
801034fe:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103501:	74 68                	je     8010356b <startothers+0xc5>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103503:	e8 97 f5 ff ff       	call   80102a9f <kalloc>
80103508:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010350b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350e:	83 e8 04             	sub    $0x4,%eax
80103511:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103514:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010351a:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010351c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010351f:	83 e8 08             	sub    $0x8,%eax
80103522:	c7 00 46 34 10 80    	movl   $0x80103446,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010352b:	8d 58 f4             	lea    -0xc(%eax),%ebx
8010352e:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80103535:	e8 1e fe ff ff       	call   80103358 <v2p>
8010353a:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
8010353c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010353f:	89 04 24             	mov    %eax,(%esp)
80103542:	e8 11 fe ff ff       	call   80103358 <v2p>
80103547:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010354a:	8a 12                	mov    (%edx),%dl
8010354c:	0f b6 d2             	movzbl %dl,%edx
8010354f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103553:	89 14 24             	mov    %edx,(%esp)
80103556:	e8 50 f9 ff ff       	call   80102eab <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010355b:	90                   	nop
8010355c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010355f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103565:	85 c0                	test   %eax,%eax
80103567:	74 f3                	je     8010355c <startothers+0xb6>
80103569:	eb 01                	jmp    8010356c <startothers+0xc6>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
8010356b:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010356c:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103573:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103578:	89 c2                	mov    %eax,%edx
8010357a:	89 d0                	mov    %edx,%eax
8010357c:	d1 e0                	shl    %eax
8010357e:	01 d0                	add    %edx,%eax
80103580:	c1 e0 04             	shl    $0x4,%eax
80103583:	29 d0                	sub    %edx,%eax
80103585:	c1 e0 02             	shl    $0x2,%eax
80103588:	05 40 f9 10 80       	add    $0x8010f940,%eax
8010358d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103590:	0f 87 4e ff ff ff    	ja     801034e4 <startothers+0x3e>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103596:	83 c4 24             	add    $0x24,%esp
80103599:	5b                   	pop    %ebx
8010359a:	5d                   	pop    %ebp
8010359b:	c3                   	ret    

8010359c <p2v>:
8010359c:	55                   	push   %ebp
8010359d:	89 e5                	mov    %esp,%ebp
8010359f:	8b 45 08             	mov    0x8(%ebp),%eax
801035a2:	05 00 00 00 80       	add    $0x80000000,%eax
801035a7:	5d                   	pop    %ebp
801035a8:	c3                   	ret    

801035a9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801035a9:	55                   	push   %ebp
801035aa:	89 e5                	mov    %esp,%ebp
801035ac:	53                   	push   %ebx
801035ad:	83 ec 14             	sub    $0x14,%esp
801035b0:	8b 45 08             	mov    0x8(%ebp),%eax
801035b3:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801035b7:	8b 55 e8             	mov    -0x18(%ebp),%edx
801035ba:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801035be:	66 8b 55 ea          	mov    -0x16(%ebp),%dx
801035c2:	ec                   	in     (%dx),%al
801035c3:	88 c3                	mov    %al,%bl
801035c5:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801035c8:	8a 45 fb             	mov    -0x5(%ebp),%al
}
801035cb:	83 c4 14             	add    $0x14,%esp
801035ce:	5b                   	pop    %ebx
801035cf:	5d                   	pop    %ebp
801035d0:	c3                   	ret    

801035d1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801035d1:	55                   	push   %ebp
801035d2:	89 e5                	mov    %esp,%ebp
801035d4:	83 ec 08             	sub    $0x8,%esp
801035d7:	8b 45 08             	mov    0x8(%ebp),%eax
801035da:	8b 55 0c             	mov    0xc(%ebp),%edx
801035dd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801035e1:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801035e4:	8a 45 f8             	mov    -0x8(%ebp),%al
801035e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
801035ea:	ee                   	out    %al,(%dx)
}
801035eb:	c9                   	leave  
801035ec:	c3                   	ret    

801035ed <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801035ed:	55                   	push   %ebp
801035ee:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801035f0:	a1 64 b6 10 80       	mov    0x8010b664,%eax
801035f5:	89 c2                	mov    %eax,%edx
801035f7:	b8 40 f9 10 80       	mov    $0x8010f940,%eax
801035fc:	89 d1                	mov    %edx,%ecx
801035fe:	29 c1                	sub    %eax,%ecx
80103600:	89 c8                	mov    %ecx,%eax
80103602:	89 c2                	mov    %eax,%edx
80103604:	c1 fa 02             	sar    $0x2,%edx
80103607:	89 d0                	mov    %edx,%eax
80103609:	c1 e0 03             	shl    $0x3,%eax
8010360c:	01 d0                	add    %edx,%eax
8010360e:	c1 e0 03             	shl    $0x3,%eax
80103611:	01 d0                	add    %edx,%eax
80103613:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
8010361a:	01 c8                	add    %ecx,%eax
8010361c:	c1 e0 03             	shl    $0x3,%eax
8010361f:	01 d0                	add    %edx,%eax
80103621:	c1 e0 03             	shl    $0x3,%eax
80103624:	29 d0                	sub    %edx,%eax
80103626:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
8010362d:	01 c8                	add    %ecx,%eax
8010362f:	c1 e0 02             	shl    $0x2,%eax
80103632:	01 d0                	add    %edx,%eax
80103634:	c1 e0 03             	shl    $0x3,%eax
80103637:	29 d0                	sub    %edx,%eax
80103639:	89 c1                	mov    %eax,%ecx
8010363b:	c1 e1 07             	shl    $0x7,%ecx
8010363e:	01 c8                	add    %ecx,%eax
80103640:	d1 e0                	shl    %eax
80103642:	01 d0                	add    %edx,%eax
}
80103644:	5d                   	pop    %ebp
80103645:	c3                   	ret    

80103646 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103646:	55                   	push   %ebp
80103647:	89 e5                	mov    %esp,%ebp
80103649:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010364c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103653:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010365a:	eb 13                	jmp    8010366f <sum+0x29>
    sum += addr[i];
8010365c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010365f:	8b 45 08             	mov    0x8(%ebp),%eax
80103662:	01 d0                	add    %edx,%eax
80103664:	8a 00                	mov    (%eax),%al
80103666:	0f b6 c0             	movzbl %al,%eax
80103669:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
8010366c:	ff 45 fc             	incl   -0x4(%ebp)
8010366f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103672:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103675:	7c e5                	jl     8010365c <sum+0x16>
    sum += addr[i];
  return sum;
80103677:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010367a:	c9                   	leave  
8010367b:	c3                   	ret    

8010367c <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010367c:	55                   	push   %ebp
8010367d:	89 e5                	mov    %esp,%ebp
8010367f:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103682:	8b 45 08             	mov    0x8(%ebp),%eax
80103685:	89 04 24             	mov    %eax,(%esp)
80103688:	e8 0f ff ff ff       	call   8010359c <p2v>
8010368d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103690:	8b 55 0c             	mov    0xc(%ebp),%edx
80103693:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103696:	01 d0                	add    %edx,%eax
80103698:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
8010369b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010369e:	89 45 f4             	mov    %eax,-0xc(%ebp)
801036a1:	eb 3f                	jmp    801036e2 <mpsearch1+0x66>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801036a3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801036aa:	00 
801036ab:	c7 44 24 04 1c 84 10 	movl   $0x8010841c,0x4(%esp)
801036b2:	80 
801036b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b6:	89 04 24             	mov    %eax,(%esp)
801036b9:	e8 37 17 00 00       	call   80104df5 <memcmp>
801036be:	85 c0                	test   %eax,%eax
801036c0:	75 1c                	jne    801036de <mpsearch1+0x62>
801036c2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801036c9:	00 
801036ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036cd:	89 04 24             	mov    %eax,(%esp)
801036d0:	e8 71 ff ff ff       	call   80103646 <sum>
801036d5:	84 c0                	test   %al,%al
801036d7:	75 05                	jne    801036de <mpsearch1+0x62>
      return (struct mp*)p;
801036d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036dc:	eb 11                	jmp    801036ef <mpsearch1+0x73>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
801036de:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801036e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801036e8:	72 b9                	jb     801036a3 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
801036ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801036ef:	c9                   	leave  
801036f0:	c3                   	ret    

801036f1 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801036f1:	55                   	push   %ebp
801036f2:	89 e5                	mov    %esp,%ebp
801036f4:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801036f7:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801036fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103701:	83 c0 0f             	add    $0xf,%eax
80103704:	8a 00                	mov    (%eax),%al
80103706:	0f b6 c0             	movzbl %al,%eax
80103709:	89 c2                	mov    %eax,%edx
8010370b:	c1 e2 08             	shl    $0x8,%edx
8010370e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103711:	83 c0 0e             	add    $0xe,%eax
80103714:	8a 00                	mov    (%eax),%al
80103716:	0f b6 c0             	movzbl %al,%eax
80103719:	09 d0                	or     %edx,%eax
8010371b:	c1 e0 04             	shl    $0x4,%eax
8010371e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103721:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103725:	74 21                	je     80103748 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103727:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010372e:	00 
8010372f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103732:	89 04 24             	mov    %eax,(%esp)
80103735:	e8 42 ff ff ff       	call   8010367c <mpsearch1>
8010373a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010373d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103741:	74 4e                	je     80103791 <mpsearch+0xa0>
      return mp;
80103743:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103746:	eb 5d                	jmp    801037a5 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374b:	83 c0 14             	add    $0x14,%eax
8010374e:	8a 00                	mov    (%eax),%al
80103750:	0f b6 c0             	movzbl %al,%eax
80103753:	89 c2                	mov    %eax,%edx
80103755:	c1 e2 08             	shl    $0x8,%edx
80103758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010375b:	83 c0 13             	add    $0x13,%eax
8010375e:	8a 00                	mov    (%eax),%al
80103760:	0f b6 c0             	movzbl %al,%eax
80103763:	09 d0                	or     %edx,%eax
80103765:	c1 e0 0a             	shl    $0xa,%eax
80103768:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
8010376b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010376e:	2d 00 04 00 00       	sub    $0x400,%eax
80103773:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
8010377a:	00 
8010377b:	89 04 24             	mov    %eax,(%esp)
8010377e:	e8 f9 fe ff ff       	call   8010367c <mpsearch1>
80103783:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103786:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010378a:	74 05                	je     80103791 <mpsearch+0xa0>
      return mp;
8010378c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010378f:	eb 14                	jmp    801037a5 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103791:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103798:	00 
80103799:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
801037a0:	e8 d7 fe ff ff       	call   8010367c <mpsearch1>
}
801037a5:	c9                   	leave  
801037a6:	c3                   	ret    

801037a7 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
801037a7:	55                   	push   %ebp
801037a8:	89 e5                	mov    %esp,%ebp
801037aa:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801037ad:	e8 3f ff ff ff       	call   801036f1 <mpsearch>
801037b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801037b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037b9:	74 0a                	je     801037c5 <mpconfig+0x1e>
801037bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037be:	8b 40 04             	mov    0x4(%eax),%eax
801037c1:	85 c0                	test   %eax,%eax
801037c3:	75 0a                	jne    801037cf <mpconfig+0x28>
    return 0;
801037c5:	b8 00 00 00 00       	mov    $0x0,%eax
801037ca:	e9 80 00 00 00       	jmp    8010384f <mpconfig+0xa8>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
801037cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037d2:	8b 40 04             	mov    0x4(%eax),%eax
801037d5:	89 04 24             	mov    %eax,(%esp)
801037d8:	e8 bf fd ff ff       	call   8010359c <p2v>
801037dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801037e0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
801037e7:	00 
801037e8:	c7 44 24 04 21 84 10 	movl   $0x80108421,0x4(%esp)
801037ef:	80 
801037f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037f3:	89 04 24             	mov    %eax,(%esp)
801037f6:	e8 fa 15 00 00       	call   80104df5 <memcmp>
801037fb:	85 c0                	test   %eax,%eax
801037fd:	74 07                	je     80103806 <mpconfig+0x5f>
    return 0;
801037ff:	b8 00 00 00 00       	mov    $0x0,%eax
80103804:	eb 49                	jmp    8010384f <mpconfig+0xa8>
  if(conf->version != 1 && conf->version != 4)
80103806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103809:	8a 40 06             	mov    0x6(%eax),%al
8010380c:	3c 01                	cmp    $0x1,%al
8010380e:	74 11                	je     80103821 <mpconfig+0x7a>
80103810:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103813:	8a 40 06             	mov    0x6(%eax),%al
80103816:	3c 04                	cmp    $0x4,%al
80103818:	74 07                	je     80103821 <mpconfig+0x7a>
    return 0;
8010381a:	b8 00 00 00 00       	mov    $0x0,%eax
8010381f:	eb 2e                	jmp    8010384f <mpconfig+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103824:	8b 40 04             	mov    0x4(%eax),%eax
80103827:	0f b7 c0             	movzwl %ax,%eax
8010382a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010382e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103831:	89 04 24             	mov    %eax,(%esp)
80103834:	e8 0d fe ff ff       	call   80103646 <sum>
80103839:	84 c0                	test   %al,%al
8010383b:	74 07                	je     80103844 <mpconfig+0x9d>
    return 0;
8010383d:	b8 00 00 00 00       	mov    $0x0,%eax
80103842:	eb 0b                	jmp    8010384f <mpconfig+0xa8>
  *pmp = mp;
80103844:	8b 45 08             	mov    0x8(%ebp),%eax
80103847:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010384a:	89 10                	mov    %edx,(%eax)
  return conf;
8010384c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010384f:	c9                   	leave  
80103850:	c3                   	ret    

80103851 <mpinit>:

void
mpinit(void)
{
80103851:	55                   	push   %ebp
80103852:	89 e5                	mov    %esp,%ebp
80103854:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103857:	c7 05 64 b6 10 80 40 	movl   $0x8010f940,0x8010b664
8010385e:	f9 10 80 
  if((conf = mpconfig(&mp)) == 0)
80103861:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103864:	89 04 24             	mov    %eax,(%esp)
80103867:	e8 3b ff ff ff       	call   801037a7 <mpconfig>
8010386c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010386f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103873:	0f 84 a4 01 00 00    	je     80103a1d <mpinit+0x1cc>
    return;
  ismp = 1;
80103879:	c7 05 24 f9 10 80 01 	movl   $0x1,0x8010f924
80103880:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103883:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103886:	8b 40 24             	mov    0x24(%eax),%eax
80103889:	a3 9c f8 10 80       	mov    %eax,0x8010f89c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010388e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103891:	83 c0 2c             	add    $0x2c,%eax
80103894:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103897:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010389a:	8b 40 04             	mov    0x4(%eax),%eax
8010389d:	0f b7 d0             	movzwl %ax,%edx
801038a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a3:	01 d0                	add    %edx,%eax
801038a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801038a8:	e9 fe 00 00 00       	jmp    801039ab <mpinit+0x15a>
    switch(*p){
801038ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038b0:	8a 00                	mov    (%eax),%al
801038b2:	0f b6 c0             	movzbl %al,%eax
801038b5:	83 f8 04             	cmp    $0x4,%eax
801038b8:	0f 87 cb 00 00 00    	ja     80103989 <mpinit+0x138>
801038be:	8b 04 85 64 84 10 80 	mov    -0x7fef7b9c(,%eax,4),%eax
801038c5:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
801038c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
801038cd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038d0:	8a 40 01             	mov    0x1(%eax),%al
801038d3:	0f b6 d0             	movzbl %al,%edx
801038d6:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801038db:	39 c2                	cmp    %eax,%edx
801038dd:	74 2c                	je     8010390b <mpinit+0xba>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801038df:	8b 45 e8             	mov    -0x18(%ebp),%eax
801038e2:	8a 40 01             	mov    0x1(%eax),%al
801038e5:	0f b6 d0             	movzbl %al,%edx
801038e8:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
801038ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801038f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801038f5:	c7 04 24 26 84 10 80 	movl   $0x80108426,(%esp)
801038fc:	e8 a0 ca ff ff       	call   801003a1 <cprintf>
        ismp = 0;
80103901:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
80103908:	00 00 00 
      }
      if(proc->flags & MPBOOT)
8010390b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010390e:	8a 40 03             	mov    0x3(%eax),%al
80103911:	0f b6 c0             	movzbl %al,%eax
80103914:	83 e0 02             	and    $0x2,%eax
80103917:	85 c0                	test   %eax,%eax
80103919:	74 1e                	je     80103939 <mpinit+0xe8>
        bcpu = &cpus[ncpu];
8010391b:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
80103921:	89 d0                	mov    %edx,%eax
80103923:	d1 e0                	shl    %eax
80103925:	01 d0                	add    %edx,%eax
80103927:	c1 e0 04             	shl    $0x4,%eax
8010392a:	29 d0                	sub    %edx,%eax
8010392c:	c1 e0 02             	shl    $0x2,%eax
8010392f:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103934:	a3 64 b6 10 80       	mov    %eax,0x8010b664
      cpus[ncpu].id = ncpu;
80103939:	8b 15 20 ff 10 80    	mov    0x8010ff20,%edx
8010393f:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103944:	88 c1                	mov    %al,%cl
80103946:	89 d0                	mov    %edx,%eax
80103948:	d1 e0                	shl    %eax
8010394a:	01 d0                	add    %edx,%eax
8010394c:	c1 e0 04             	shl    $0x4,%eax
8010394f:	29 d0                	sub    %edx,%eax
80103951:	c1 e0 02             	shl    $0x2,%eax
80103954:	05 40 f9 10 80       	add    $0x8010f940,%eax
80103959:	88 08                	mov    %cl,(%eax)
      ncpu++;
8010395b:	a1 20 ff 10 80       	mov    0x8010ff20,%eax
80103960:	40                   	inc    %eax
80103961:	a3 20 ff 10 80       	mov    %eax,0x8010ff20
      p += sizeof(struct mpproc);
80103966:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010396a:	eb 3f                	jmp    801039ab <mpinit+0x15a>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010396c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010396f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103972:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103975:	8a 40 01             	mov    0x1(%eax),%al
80103978:	a2 20 f9 10 80       	mov    %al,0x8010f920
      p += sizeof(struct mpioapic);
8010397d:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103981:	eb 28                	jmp    801039ab <mpinit+0x15a>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103983:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103987:	eb 22                	jmp    801039ab <mpinit+0x15a>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010398c:	8a 00                	mov    (%eax),%al
8010398e:	0f b6 c0             	movzbl %al,%eax
80103991:	89 44 24 04          	mov    %eax,0x4(%esp)
80103995:	c7 04 24 44 84 10 80 	movl   $0x80108444,(%esp)
8010399c:	e8 00 ca ff ff       	call   801003a1 <cprintf>
      ismp = 0;
801039a1:	c7 05 24 f9 10 80 00 	movl   $0x0,0x8010f924
801039a8:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801039ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ae:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801039b1:	0f 82 f6 fe ff ff    	jb     801038ad <mpinit+0x5c>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
801039b7:	a1 24 f9 10 80       	mov    0x8010f924,%eax
801039bc:	85 c0                	test   %eax,%eax
801039be:	75 1d                	jne    801039dd <mpinit+0x18c>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801039c0:	c7 05 20 ff 10 80 01 	movl   $0x1,0x8010ff20
801039c7:	00 00 00 
    lapic = 0;
801039ca:	c7 05 9c f8 10 80 00 	movl   $0x0,0x8010f89c
801039d1:	00 00 00 
    ioapicid = 0;
801039d4:	c6 05 20 f9 10 80 00 	movb   $0x0,0x8010f920
801039db:	eb 40                	jmp    80103a1d <mpinit+0x1cc>
    return;
  }

  if(mp->imcrp){
801039dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801039e0:	8a 40 0c             	mov    0xc(%eax),%al
801039e3:	84 c0                	test   %al,%al
801039e5:	74 36                	je     80103a1d <mpinit+0x1cc>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801039e7:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
801039ee:	00 
801039ef:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
801039f6:	e8 d6 fb ff ff       	call   801035d1 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801039fb:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a02:	e8 a2 fb ff ff       	call   801035a9 <inb>
80103a07:	83 c8 01             	or     $0x1,%eax
80103a0a:	0f b6 c0             	movzbl %al,%eax
80103a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a11:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103a18:	e8 b4 fb ff ff       	call   801035d1 <outb>
  }
}
80103a1d:	c9                   	leave  
80103a1e:	c3                   	ret    
80103a1f:	90                   	nop

80103a20 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a20:	55                   	push   %ebp
80103a21:	89 e5                	mov    %esp,%ebp
80103a23:	83 ec 08             	sub    $0x8,%esp
80103a26:	8b 45 08             	mov    0x8(%ebp),%eax
80103a29:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a30:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a33:	8a 45 f8             	mov    -0x8(%ebp),%al
80103a36:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a39:	ee                   	out    %al,(%dx)
}
80103a3a:	c9                   	leave  
80103a3b:	c3                   	ret    

80103a3c <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103a3c:	55                   	push   %ebp
80103a3d:	89 e5                	mov    %esp,%ebp
80103a3f:	83 ec 0c             	sub    $0xc,%esp
80103a42:	8b 45 08             	mov    0x8(%ebp),%eax
80103a45:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a4c:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103a52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a55:	0f b6 c0             	movzbl %al,%eax
80103a58:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a5c:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103a63:	e8 b8 ff ff ff       	call   80103a20 <outb>
  outb(IO_PIC2+1, mask >> 8);
80103a68:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a6b:	66 c1 e8 08          	shr    $0x8,%ax
80103a6f:	0f b6 c0             	movzbl %al,%eax
80103a72:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a76:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103a7d:	e8 9e ff ff ff       	call   80103a20 <outb>
}
80103a82:	c9                   	leave  
80103a83:	c3                   	ret    

80103a84 <picenable>:

void
picenable(int irq)
{
80103a84:	55                   	push   %ebp
80103a85:	89 e5                	mov    %esp,%ebp
80103a87:	53                   	push   %ebx
80103a88:	83 ec 04             	sub    $0x4,%esp
  picsetmask(irqmask & ~(1<<irq));
80103a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8e:	ba 01 00 00 00       	mov    $0x1,%edx
80103a93:	89 d3                	mov    %edx,%ebx
80103a95:	88 c1                	mov    %al,%cl
80103a97:	d3 e3                	shl    %cl,%ebx
80103a99:	89 d8                	mov    %ebx,%eax
80103a9b:	89 c2                	mov    %eax,%edx
80103a9d:	f7 d2                	not    %edx
80103a9f:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103aa5:	21 d0                	and    %edx,%eax
80103aa7:	0f b7 c0             	movzwl %ax,%eax
80103aaa:	89 04 24             	mov    %eax,(%esp)
80103aad:	e8 8a ff ff ff       	call   80103a3c <picsetmask>
}
80103ab2:	83 c4 04             	add    $0x4,%esp
80103ab5:	5b                   	pop    %ebx
80103ab6:	5d                   	pop    %ebp
80103ab7:	c3                   	ret    

80103ab8 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ab8:	55                   	push   %ebp
80103ab9:	89 e5                	mov    %esp,%ebp
80103abb:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103abe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ac5:	00 
80103ac6:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103acd:	e8 4e ff ff ff       	call   80103a20 <outb>
  outb(IO_PIC2+1, 0xFF);
80103ad2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ad9:	00 
80103ada:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ae1:	e8 3a ff ff ff       	call   80103a20 <outb>

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103ae6:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103aed:	00 
80103aee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103af5:	e8 26 ff ff ff       	call   80103a20 <outb>

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103afa:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
80103b01:	00 
80103b02:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b09:	e8 12 ff ff ff       	call   80103a20 <outb>

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103b0e:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
80103b15:	00 
80103b16:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b1d:	e8 fe fe ff ff       	call   80103a20 <outb>
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103b22:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b29:	00 
80103b2a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103b31:	e8 ea fe ff ff       	call   80103a20 <outb>

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103b36:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
80103b3d:	00 
80103b3e:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103b45:	e8 d6 fe ff ff       	call   80103a20 <outb>
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103b4a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
80103b51:	00 
80103b52:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b59:	e8 c2 fe ff ff       	call   80103a20 <outb>
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103b5e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80103b65:	00 
80103b66:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b6d:	e8 ae fe ff ff       	call   80103a20 <outb>
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103b72:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80103b79:	00 
80103b7a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103b81:	e8 9a fe ff ff       	call   80103a20 <outb>

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103b86:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103b8d:	00 
80103b8e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103b95:	e8 86 fe ff ff       	call   80103a20 <outb>
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103b9a:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103ba1:	00 
80103ba2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103ba9:	e8 72 fe ff ff       	call   80103a20 <outb>

  outb(IO_PIC2, 0x68);             // OCW3
80103bae:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
80103bb5:	00 
80103bb6:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bbd:	e8 5e fe ff ff       	call   80103a20 <outb>
  outb(IO_PIC2, 0x0a);             // OCW3
80103bc2:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103bc9:	00 
80103bca:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103bd1:	e8 4a fe ff ff       	call   80103a20 <outb>

  if(irqmask != 0xFFFF)
80103bd6:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103bdc:	66 83 f8 ff          	cmp    $0xffff,%ax
80103be0:	74 11                	je     80103bf3 <picinit+0x13b>
    picsetmask(irqmask);
80103be2:	66 a1 00 b0 10 80    	mov    0x8010b000,%ax
80103be8:	0f b7 c0             	movzwl %ax,%eax
80103beb:	89 04 24             	mov    %eax,(%esp)
80103bee:	e8 49 fe ff ff       	call   80103a3c <picsetmask>
}
80103bf3:	c9                   	leave  
80103bf4:	c3                   	ret    
80103bf5:	66 90                	xchg   %ax,%ax
80103bf7:	90                   	nop

80103bf8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103bf8:	55                   	push   %ebp
80103bf9:	89 e5                	mov    %esp,%ebp
80103bfb:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103bfe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103c05:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c11:	8b 10                	mov    (%eax),%edx
80103c13:	8b 45 08             	mov    0x8(%ebp),%eax
80103c16:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103c18:	e8 d7 d2 ff ff       	call   80100ef4 <filealloc>
80103c1d:	8b 55 08             	mov    0x8(%ebp),%edx
80103c20:	89 02                	mov    %eax,(%edx)
80103c22:	8b 45 08             	mov    0x8(%ebp),%eax
80103c25:	8b 00                	mov    (%eax),%eax
80103c27:	85 c0                	test   %eax,%eax
80103c29:	0f 84 c8 00 00 00    	je     80103cf7 <pipealloc+0xff>
80103c2f:	e8 c0 d2 ff ff       	call   80100ef4 <filealloc>
80103c34:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c37:	89 02                	mov    %eax,(%edx)
80103c39:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c3c:	8b 00                	mov    (%eax),%eax
80103c3e:	85 c0                	test   %eax,%eax
80103c40:	0f 84 b1 00 00 00    	je     80103cf7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103c46:	e8 54 ee ff ff       	call   80102a9f <kalloc>
80103c4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c52:	0f 84 9e 00 00 00    	je     80103cf6 <pipealloc+0xfe>
    goto bad;
  p->readopen = 1;
80103c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5b:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103c62:	00 00 00 
  p->writeopen = 1;
80103c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c68:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103c6f:	00 00 00 
  p->nwrite = 0;
80103c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c75:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103c7c:	00 00 00 
  p->nread = 0;
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103c89:	00 00 00 
  initlock(&p->lock, "pipe");
80103c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8f:	c7 44 24 04 78 84 10 	movl   $0x80108478,0x4(%esp)
80103c96:	80 
80103c97:	89 04 24             	mov    %eax,(%esp)
80103c9a:	e8 6b 0e 00 00       	call   80104b0a <initlock>
  (*f0)->type = FD_PIPE;
80103c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103ca2:	8b 00                	mov    (%eax),%eax
80103ca4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103caa:	8b 45 08             	mov    0x8(%ebp),%eax
80103cad:	8b 00                	mov    (%eax),%eax
80103caf:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103cb3:	8b 45 08             	mov    0x8(%ebp),%eax
80103cb6:	8b 00                	mov    (%eax),%eax
80103cb8:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103cbc:	8b 45 08             	mov    0x8(%ebp),%eax
80103cbf:	8b 00                	mov    (%eax),%eax
80103cc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cc4:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cca:	8b 00                	mov    (%eax),%eax
80103ccc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cd5:	8b 00                	mov    (%eax),%eax
80103cd7:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103cde:	8b 00                	mov    (%eax),%eax
80103ce0:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ce7:	8b 00                	mov    (%eax),%eax
80103ce9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cec:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103cef:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf4:	eb 43                	jmp    80103d39 <pipealloc+0x141>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80103cf6:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80103cf7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cfb:	74 0b                	je     80103d08 <pipealloc+0x110>
    kfree((char*)p);
80103cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d00:	89 04 24             	mov    %eax,(%esp)
80103d03:	e8 fe ec ff ff       	call   80102a06 <kfree>
  if(*f0)
80103d08:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0b:	8b 00                	mov    (%eax),%eax
80103d0d:	85 c0                	test   %eax,%eax
80103d0f:	74 0d                	je     80103d1e <pipealloc+0x126>
    fileclose(*f0);
80103d11:	8b 45 08             	mov    0x8(%ebp),%eax
80103d14:	8b 00                	mov    (%eax),%eax
80103d16:	89 04 24             	mov    %eax,(%esp)
80103d19:	e8 7e d2 ff ff       	call   80100f9c <fileclose>
  if(*f1)
80103d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d21:	8b 00                	mov    (%eax),%eax
80103d23:	85 c0                	test   %eax,%eax
80103d25:	74 0d                	je     80103d34 <pipealloc+0x13c>
    fileclose(*f1);
80103d27:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d2a:	8b 00                	mov    (%eax),%eax
80103d2c:	89 04 24             	mov    %eax,(%esp)
80103d2f:	e8 68 d2 ff ff       	call   80100f9c <fileclose>
  return -1;
80103d34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103d39:	c9                   	leave  
80103d3a:	c3                   	ret    

80103d3b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103d3b:	55                   	push   %ebp
80103d3c:	89 e5                	mov    %esp,%ebp
80103d3e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103d41:	8b 45 08             	mov    0x8(%ebp),%eax
80103d44:	89 04 24             	mov    %eax,(%esp)
80103d47:	e8 df 0d 00 00       	call   80104b2b <acquire>
  if(writable){
80103d4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103d50:	74 1f                	je     80103d71 <pipeclose+0x36>
    p->writeopen = 0;
80103d52:	8b 45 08             	mov    0x8(%ebp),%eax
80103d55:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103d5c:	00 00 00 
    wakeup(&p->nread);
80103d5f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d62:	05 34 02 00 00       	add    $0x234,%eax
80103d67:	89 04 24             	mov    %eax,(%esp)
80103d6a:	e8 70 0b 00 00       	call   801048df <wakeup>
80103d6f:	eb 1d                	jmp    80103d8e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103d71:	8b 45 08             	mov    0x8(%ebp),%eax
80103d74:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103d7b:	00 00 00 
    wakeup(&p->nwrite);
80103d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d81:	05 38 02 00 00       	add    $0x238,%eax
80103d86:	89 04 24             	mov    %eax,(%esp)
80103d89:	e8 51 0b 00 00       	call   801048df <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d91:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103d97:	85 c0                	test   %eax,%eax
80103d99:	75 25                	jne    80103dc0 <pipeclose+0x85>
80103d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103da4:	85 c0                	test   %eax,%eax
80103da6:	75 18                	jne    80103dc0 <pipeclose+0x85>
    release(&p->lock);
80103da8:	8b 45 08             	mov    0x8(%ebp),%eax
80103dab:	89 04 24             	mov    %eax,(%esp)
80103dae:	e8 da 0d 00 00       	call   80104b8d <release>
    kfree((char*)p);
80103db3:	8b 45 08             	mov    0x8(%ebp),%eax
80103db6:	89 04 24             	mov    %eax,(%esp)
80103db9:	e8 48 ec ff ff       	call   80102a06 <kfree>
80103dbe:	eb 0b                	jmp    80103dcb <pipeclose+0x90>
  } else
    release(&p->lock);
80103dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc3:	89 04 24             	mov    %eax,(%esp)
80103dc6:	e8 c2 0d 00 00       	call   80104b8d <release>
}
80103dcb:	c9                   	leave  
80103dcc:	c3                   	ret    

80103dcd <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103dcd:	55                   	push   %ebp
80103dce:	89 e5                	mov    %esp,%ebp
80103dd0:	53                   	push   %ebx
80103dd1:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80103dd7:	89 04 24             	mov    %eax,(%esp)
80103dda:	e8 4c 0d 00 00       	call   80104b2b <acquire>
  for(i = 0; i < n; i++){
80103ddf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103de6:	e9 a6 00 00 00       	jmp    80103e91 <pipewrite+0xc4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80103deb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dee:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103df4:	85 c0                	test   %eax,%eax
80103df6:	74 0d                	je     80103e05 <pipewrite+0x38>
80103df8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103dfe:	8b 40 24             	mov    0x24(%eax),%eax
80103e01:	85 c0                	test   %eax,%eax
80103e03:	74 15                	je     80103e1a <pipewrite+0x4d>
        release(&p->lock);
80103e05:	8b 45 08             	mov    0x8(%ebp),%eax
80103e08:	89 04 24             	mov    %eax,(%esp)
80103e0b:	e8 7d 0d 00 00       	call   80104b8d <release>
        return -1;
80103e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e15:	e9 9d 00 00 00       	jmp    80103eb7 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103e1a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1d:	05 34 02 00 00       	add    $0x234,%eax
80103e22:	89 04 24             	mov    %eax,(%esp)
80103e25:	e8 b5 0a 00 00       	call   801048df <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2d:	8b 55 08             	mov    0x8(%ebp),%edx
80103e30:	81 c2 38 02 00 00    	add    $0x238,%edx
80103e36:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e3a:	89 14 24             	mov    %edx,(%esp)
80103e3d:	e8 c1 09 00 00       	call   80104803 <sleep>
80103e42:	eb 01                	jmp    80103e45 <pipewrite+0x78>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103e44:	90                   	nop
80103e45:	8b 45 08             	mov    0x8(%ebp),%eax
80103e48:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80103e51:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103e57:	05 00 02 00 00       	add    $0x200,%eax
80103e5c:	39 c2                	cmp    %eax,%edx
80103e5e:	74 8b                	je     80103deb <pipewrite+0x1e>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103e60:	8b 45 08             	mov    0x8(%ebp),%eax
80103e63:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103e69:	89 c3                	mov    %eax,%ebx
80103e6b:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103e71:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80103e74:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e77:	01 ca                	add    %ecx,%edx
80103e79:	8a 0a                	mov    (%edx),%cl
80103e7b:	8b 55 08             	mov    0x8(%ebp),%edx
80103e7e:	88 4c 1a 34          	mov    %cl,0x34(%edx,%ebx,1)
80103e82:	8d 50 01             	lea    0x1(%eax),%edx
80103e85:	8b 45 08             	mov    0x8(%ebp),%eax
80103e88:	89 90 38 02 00 00    	mov    %edx,0x238(%eax)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103e8e:	ff 45 f4             	incl   -0xc(%ebp)
80103e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e94:	3b 45 10             	cmp    0x10(%ebp),%eax
80103e97:	7c ab                	jl     80103e44 <pipewrite+0x77>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103e99:	8b 45 08             	mov    0x8(%ebp),%eax
80103e9c:	05 34 02 00 00       	add    $0x234,%eax
80103ea1:	89 04 24             	mov    %eax,(%esp)
80103ea4:	e8 36 0a 00 00       	call   801048df <wakeup>
  release(&p->lock);
80103ea9:	8b 45 08             	mov    0x8(%ebp),%eax
80103eac:	89 04 24             	mov    %eax,(%esp)
80103eaf:	e8 d9 0c 00 00       	call   80104b8d <release>
  return n;
80103eb4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103eb7:	83 c4 24             	add    $0x24,%esp
80103eba:	5b                   	pop    %ebx
80103ebb:	5d                   	pop    %ebp
80103ebc:	c3                   	ret    

80103ebd <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103ebd:	55                   	push   %ebp
80103ebe:	89 e5                	mov    %esp,%ebp
80103ec0:	53                   	push   %ebx
80103ec1:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80103ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec7:	89 04 24             	mov    %eax,(%esp)
80103eca:	e8 5c 0c 00 00       	call   80104b2b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103ecf:	eb 3a                	jmp    80103f0b <piperead+0x4e>
    if(proc->killed){
80103ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80103ed7:	8b 40 24             	mov    0x24(%eax),%eax
80103eda:	85 c0                	test   %eax,%eax
80103edc:	74 15                	je     80103ef3 <piperead+0x36>
      release(&p->lock);
80103ede:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee1:	89 04 24             	mov    %eax,(%esp)
80103ee4:	e8 a4 0c 00 00       	call   80104b8d <release>
      return -1;
80103ee9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103eee:	e9 b5 00 00 00       	jmp    80103fa8 <piperead+0xeb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103ef3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef6:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef9:	81 c2 34 02 00 00    	add    $0x234,%edx
80103eff:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f03:	89 14 24             	mov    %edx,(%esp)
80103f06:	e8 f8 08 00 00       	call   80104803 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103f0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0e:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f14:	8b 45 08             	mov    0x8(%ebp),%eax
80103f17:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f1d:	39 c2                	cmp    %eax,%edx
80103f1f:	75 0d                	jne    80103f2e <piperead+0x71>
80103f21:	8b 45 08             	mov    0x8(%ebp),%eax
80103f24:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f2a:	85 c0                	test   %eax,%eax
80103f2c:	75 a3                	jne    80103ed1 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f35:	eb 48                	jmp    80103f7f <piperead+0xc2>
    if(p->nread == p->nwrite)
80103f37:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3a:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80103f40:	8b 45 08             	mov    0x8(%ebp),%eax
80103f43:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103f49:	39 c2                	cmp    %eax,%edx
80103f4b:	74 3c                	je     80103f89 <piperead+0xcc>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103f4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f50:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f53:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80103f56:	8b 45 08             	mov    0x8(%ebp),%eax
80103f59:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103f5f:	89 c3                	mov    %eax,%ebx
80103f61:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
80103f67:	8b 55 08             	mov    0x8(%ebp),%edx
80103f6a:	8a 54 1a 34          	mov    0x34(%edx,%ebx,1),%dl
80103f6e:	88 11                	mov    %dl,(%ecx)
80103f70:	8d 50 01             	lea    0x1(%eax),%edx
80103f73:	8b 45 08             	mov    0x8(%ebp),%eax
80103f76:	89 90 34 02 00 00    	mov    %edx,0x234(%eax)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103f7c:	ff 45 f4             	incl   -0xc(%ebp)
80103f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f82:	3b 45 10             	cmp    0x10(%ebp),%eax
80103f85:	7c b0                	jl     80103f37 <piperead+0x7a>
80103f87:	eb 01                	jmp    80103f8a <piperead+0xcd>
    if(p->nread == p->nwrite)
      break;
80103f89:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8d:	05 38 02 00 00       	add    $0x238,%eax
80103f92:	89 04 24             	mov    %eax,(%esp)
80103f95:	e8 45 09 00 00       	call   801048df <wakeup>
  release(&p->lock);
80103f9a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9d:	89 04 24             	mov    %eax,(%esp)
80103fa0:	e8 e8 0b 00 00       	call   80104b8d <release>
  return i;
80103fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103fa8:	83 c4 24             	add    $0x24,%esp
80103fab:	5b                   	pop    %ebx
80103fac:	5d                   	pop    %ebp
80103fad:	c3                   	ret    
80103fae:	66 90                	xchg   %ax,%ax

80103fb0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80103fb0:	55                   	push   %ebp
80103fb1:	89 e5                	mov    %esp,%ebp
80103fb3:	53                   	push   %ebx
80103fb4:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103fb7:	9c                   	pushf  
80103fb8:	5b                   	pop    %ebx
80103fb9:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80103fbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103fbf:	83 c4 10             	add    $0x10,%esp
80103fc2:	5b                   	pop    %ebx
80103fc3:	5d                   	pop    %ebp
80103fc4:	c3                   	ret    

80103fc5 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80103fc5:	55                   	push   %ebp
80103fc6:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80103fc8:	fb                   	sti    
}
80103fc9:	5d                   	pop    %ebp
80103fca:	c3                   	ret    

80103fcb <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80103fcb:	55                   	push   %ebp
80103fcc:	89 e5                	mov    %esp,%ebp
80103fce:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80103fd1:	c7 44 24 04 7d 84 10 	movl   $0x8010847d,0x4(%esp)
80103fd8:	80 
80103fd9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80103fe0:	e8 25 0b 00 00       	call   80104b0a <initlock>
}
80103fe5:	c9                   	leave  
80103fe6:	c3                   	ret    

80103fe7 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103fe7:	55                   	push   %ebp
80103fe8:	89 e5                	mov    %esp,%ebp
80103fea:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103fed:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80103ff4:	e8 32 0b 00 00       	call   80104b2b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ff9:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104000:	eb 11                	jmp    80104013 <allocproc+0x2c>
    if(p->state == UNUSED)
80104002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104005:	8b 40 0c             	mov    0xc(%eax),%eax
80104008:	85 c0                	test   %eax,%eax
8010400a:	74 26                	je     80104032 <allocproc+0x4b>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010400c:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104013:	81 7d f4 74 22 11 80 	cmpl   $0x80112274,-0xc(%ebp)
8010401a:	72 e6                	jb     80104002 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010401c:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104023:	e8 65 0b 00 00       	call   80104b8d <release>
  return 0;
80104028:	b8 00 00 00 00       	mov    $0x0,%eax
8010402d:	e9 d2 00 00 00       	jmp    80104104 <allocproc+0x11d>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104032:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104036:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010403d:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104042:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104045:	89 42 10             	mov    %eax,0x10(%edx)
80104048:	40                   	inc    %eax
80104049:	a3 04 b0 10 80       	mov    %eax,0x8010b004
  release(&ptable.lock);
8010404e:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104055:	e8 33 0b 00 00       	call   80104b8d <release>

  p->sig_flag[0] = p->sig_flag[1] = -1;
8010405a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405d:	c7 80 88 00 00 00 ff 	movl   $0xffffffff,0x88(%eax)
80104064:	ff ff ff 
80104067:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406a:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80104070:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104073:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104079:	e8 21 ea ff ff       	call   80102a9f <kalloc>
8010407e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104081:	89 42 08             	mov    %eax,0x8(%edx)
80104084:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104087:	8b 40 08             	mov    0x8(%eax),%eax
8010408a:	85 c0                	test   %eax,%eax
8010408c:	75 11                	jne    8010409f <allocproc+0xb8>
    p->state = UNUSED;
8010408e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104091:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104098:	b8 00 00 00 00       	mov    $0x0,%eax
8010409d:	eb 65                	jmp    80104104 <allocproc+0x11d>
  }
  sp = p->kstack + KSTACKSIZE;
8010409f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a2:	8b 40 08             	mov    0x8(%eax),%eax
801040a5:	05 00 10 00 00       	add    $0x1000,%eax
801040aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801040ad:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801040b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040b7:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801040ba:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801040be:	ba 44 62 10 80       	mov    $0x80106244,%edx
801040c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040c6:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801040c8:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801040cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801040d2:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801040d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d8:	8b 40 1c             	mov    0x1c(%eax),%eax
801040db:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801040e2:	00 
801040e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801040ea:	00 
801040eb:	89 04 24             	mov    %eax,(%esp)
801040ee:	e8 8b 0c 00 00       	call   80104d7e <memset>
  p->context->eip = (uint)forkret;
801040f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f6:	8b 40 1c             	mov    0x1c(%eax),%eax
801040f9:	ba d7 47 10 80       	mov    $0x801047d7,%edx
801040fe:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104101:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104104:	c9                   	leave  
80104105:	c3                   	ret    

80104106 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104106:	55                   	push   %ebp
80104107:	89 e5                	mov    %esp,%ebp
80104109:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010410c:	e8 d6 fe ff ff       	call   80103fe7 <allocproc>
80104111:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104117:	a3 68 b6 10 80       	mov    %eax,0x8010b668
  if((p->pgdir = setupkvm()) == 0)
8010411c:	e8 2f 38 00 00       	call   80107950 <setupkvm>
80104121:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104124:	89 42 04             	mov    %eax,0x4(%edx)
80104127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412a:	8b 40 04             	mov    0x4(%eax),%eax
8010412d:	85 c0                	test   %eax,%eax
8010412f:	75 0c                	jne    8010413d <userinit+0x37>
    panic("userinit: out of memory?");
80104131:	c7 04 24 84 84 10 80 	movl   $0x80108484,(%esp)
80104138:	e8 f9 c3 ff ff       	call   80100536 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010413d:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104142:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104145:	8b 40 04             	mov    0x4(%eax),%eax
80104148:	89 54 24 08          	mov    %edx,0x8(%esp)
8010414c:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
80104153:	80 
80104154:	89 04 24             	mov    %eax,(%esp)
80104157:	e8 40 3a 00 00       	call   80107b9c <inituvm>
  p->sz = PGSIZE;
8010415c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415f:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104168:	8b 40 18             	mov    0x18(%eax),%eax
8010416b:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80104172:	00 
80104173:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010417a:	00 
8010417b:	89 04 24             	mov    %eax,(%esp)
8010417e:	e8 fb 0b 00 00       	call   80104d7e <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104186:	8b 40 18             	mov    0x18(%eax),%eax
80104189:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010418f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104192:	8b 40 18             	mov    0x18(%eax),%eax
80104195:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010419b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419e:	8b 50 18             	mov    0x18(%eax),%edx
801041a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a4:	8b 40 18             	mov    0x18(%eax),%eax
801041a7:	8b 40 2c             	mov    0x2c(%eax),%eax
801041aa:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
801041ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b1:	8b 50 18             	mov    0x18(%eax),%edx
801041b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b7:	8b 40 18             	mov    0x18(%eax),%eax
801041ba:	8b 40 2c             	mov    0x2c(%eax),%eax
801041bd:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
801041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041c4:	8b 40 18             	mov    0x18(%eax),%eax
801041c7:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801041ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041d1:	8b 40 18             	mov    0x18(%eax),%eax
801041d4:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801041db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041de:	8b 40 18             	mov    0x18(%eax),%eax
801041e1:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801041e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041eb:	83 c0 6c             	add    $0x6c,%eax
801041ee:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801041f5:	00 
801041f6:	c7 44 24 04 9d 84 10 	movl   $0x8010849d,0x4(%esp)
801041fd:	80 
801041fe:	89 04 24             	mov    %eax,(%esp)
80104201:	e8 8a 0d 00 00       	call   80104f90 <safestrcpy>
  p->cwd = namei("/");
80104206:	c7 04 24 a6 84 10 80 	movl   $0x801084a6,(%esp)
8010420d:	e8 aa e1 ff ff       	call   801023bc <namei>
80104212:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104215:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80104218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010421b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
80104222:	c9                   	leave  
80104223:	c3                   	ret    

80104224 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104224:	55                   	push   %ebp
80104225:	89 e5                	mov    %esp,%ebp
80104227:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  
  sz = proc->sz;
8010422a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104230:	8b 00                	mov    (%eax),%eax
80104232:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104235:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104239:	7e 34                	jle    8010426f <growproc+0x4b>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
8010423b:	8b 55 08             	mov    0x8(%ebp),%edx
8010423e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104241:	01 c2                	add    %eax,%edx
80104243:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104249:	8b 40 04             	mov    0x4(%eax),%eax
8010424c:	89 54 24 08          	mov    %edx,0x8(%esp)
80104250:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104253:	89 54 24 04          	mov    %edx,0x4(%esp)
80104257:	89 04 24             	mov    %eax,(%esp)
8010425a:	e8 b7 3a 00 00       	call   80107d16 <allocuvm>
8010425f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104262:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104266:	75 41                	jne    801042a9 <growproc+0x85>
      return -1;
80104268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010426d:	eb 58                	jmp    801042c7 <growproc+0xa3>
  } else if(n < 0){
8010426f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104273:	79 34                	jns    801042a9 <growproc+0x85>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104275:	8b 55 08             	mov    0x8(%ebp),%edx
80104278:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010427b:	01 c2                	add    %eax,%edx
8010427d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104283:	8b 40 04             	mov    0x4(%eax),%eax
80104286:	89 54 24 08          	mov    %edx,0x8(%esp)
8010428a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010428d:	89 54 24 04          	mov    %edx,0x4(%esp)
80104291:	89 04 24             	mov    %eax,(%esp)
80104294:	e8 57 3b 00 00       	call   80107df0 <deallocuvm>
80104299:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010429c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042a0:	75 07                	jne    801042a9 <growproc+0x85>
      return -1;
801042a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a7:	eb 1e                	jmp    801042c7 <growproc+0xa3>
  }
  proc->sz = sz;
801042a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042b2:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
801042b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ba:	89 04 24             	mov    %eax,(%esp)
801042bd:	e8 7f 37 00 00       	call   80107a41 <switchuvm>
  return 0;
801042c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042c7:	c9                   	leave  
801042c8:	c3                   	ret    

801042c9 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801042c9:	55                   	push   %ebp
801042ca:	89 e5                	mov    %esp,%ebp
801042cc:	57                   	push   %edi
801042cd:	56                   	push   %esi
801042ce:	53                   	push   %ebx
801042cf:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801042d2:	e8 10 fd ff ff       	call   80103fe7 <allocproc>
801042d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
801042da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801042de:	75 0a                	jne    801042ea <fork+0x21>
    return -1;
801042e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e5:	e9 39 01 00 00       	jmp    80104423 <fork+0x15a>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801042ea:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042f0:	8b 10                	mov    (%eax),%edx
801042f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042f8:	8b 40 04             	mov    0x4(%eax),%eax
801042fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801042ff:	89 04 24             	mov    %eax,(%esp)
80104302:	e8 84 3c 00 00       	call   80107f8b <copyuvm>
80104307:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010430a:	89 42 04             	mov    %eax,0x4(%edx)
8010430d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104310:	8b 40 04             	mov    0x4(%eax),%eax
80104313:	85 c0                	test   %eax,%eax
80104315:	75 2c                	jne    80104343 <fork+0x7a>
    kfree(np->kstack);
80104317:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010431a:	8b 40 08             	mov    0x8(%eax),%eax
8010431d:	89 04 24             	mov    %eax,(%esp)
80104320:	e8 e1 e6 ff ff       	call   80102a06 <kfree>
    np->kstack = 0;
80104325:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104328:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010432f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104332:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104339:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010433e:	e9 e0 00 00 00       	jmp    80104423 <fork+0x15a>
  }
  np->sz = proc->sz;
80104343:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104349:	8b 10                	mov    (%eax),%edx
8010434b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010434e:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104350:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104357:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010435a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010435d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104360:	8b 50 18             	mov    0x18(%eax),%edx
80104363:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104369:	8b 40 18             	mov    0x18(%eax),%eax
8010436c:	89 c3                	mov    %eax,%ebx
8010436e:	b8 13 00 00 00       	mov    $0x13,%eax
80104373:	89 d7                	mov    %edx,%edi
80104375:	89 de                	mov    %ebx,%esi
80104377:	89 c1                	mov    %eax,%ecx
80104379:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010437b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010437e:	8b 40 18             	mov    0x18(%eax),%eax
80104381:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104388:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010438f:	eb 3c                	jmp    801043cd <fork+0x104>
    if(proc->ofile[i])
80104391:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104397:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010439a:	83 c2 08             	add    $0x8,%edx
8010439d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043a1:	85 c0                	test   %eax,%eax
801043a3:	74 25                	je     801043ca <fork+0x101>
      np->ofile[i] = filedup(proc->ofile[i]);
801043a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801043ae:	83 c2 08             	add    $0x8,%edx
801043b1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801043b5:	89 04 24             	mov    %eax,(%esp)
801043b8:	e8 97 cb ff ff       	call   80100f54 <filedup>
801043bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
801043c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801043c3:	83 c1 08             	add    $0x8,%ecx
801043c6:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801043ca:	ff 45 e4             	incl   -0x1c(%ebp)
801043cd:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801043d1:	7e be                	jle    80104391 <fork+0xc8>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801043d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043d9:	8b 40 68             	mov    0x68(%eax),%eax
801043dc:	89 04 24             	mov    %eax,(%esp)
801043df:	e8 0c d4 ff ff       	call   801017f0 <idup>
801043e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801043e7:	89 42 68             	mov    %eax,0x68(%edx)
 
  pid = np->pid;
801043ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043ed:	8b 40 10             	mov    0x10(%eax),%eax
801043f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->state = RUNNABLE;
801043f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801043f6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  safestrcpy(np->name, proc->name, sizeof(proc->name));
801043fd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104403:	8d 50 6c             	lea    0x6c(%eax),%edx
80104406:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104409:	83 c0 6c             	add    $0x6c,%eax
8010440c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104413:	00 
80104414:	89 54 24 04          	mov    %edx,0x4(%esp)
80104418:	89 04 24             	mov    %eax,(%esp)
8010441b:	e8 70 0b 00 00       	call   80104f90 <safestrcpy>
  return pid;
80104420:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104423:	83 c4 2c             	add    $0x2c,%esp
80104426:	5b                   	pop    %ebx
80104427:	5e                   	pop    %esi
80104428:	5f                   	pop    %edi
80104429:	5d                   	pop    %ebp
8010442a:	c3                   	ret    

8010442b <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010442b:	55                   	push   %ebp
8010442c:	89 e5                	mov    %esp,%ebp
8010442e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104431:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104438:	a1 68 b6 10 80       	mov    0x8010b668,%eax
8010443d:	39 c2                	cmp    %eax,%edx
8010443f:	75 0c                	jne    8010444d <exit+0x22>
    panic("init exiting");
80104441:	c7 04 24 a8 84 10 80 	movl   $0x801084a8,(%esp)
80104448:	e8 e9 c0 ff ff       	call   80100536 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010444d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104454:	eb 43                	jmp    80104499 <exit+0x6e>
    if(proc->ofile[fd]){
80104456:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010445c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010445f:	83 c2 08             	add    $0x8,%edx
80104462:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104466:	85 c0                	test   %eax,%eax
80104468:	74 2c                	je     80104496 <exit+0x6b>
      fileclose(proc->ofile[fd]);
8010446a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104470:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104473:	83 c2 08             	add    $0x8,%edx
80104476:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010447a:	89 04 24             	mov    %eax,(%esp)
8010447d:	e8 1a cb ff ff       	call   80100f9c <fileclose>
      proc->ofile[fd] = 0;
80104482:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104488:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010448b:	83 c2 08             	add    $0x8,%edx
8010448e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104495:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104496:	ff 45 f0             	incl   -0x10(%ebp)
80104499:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010449d:	7e b7                	jle    80104456 <exit+0x2b>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  iput(proc->cwd);
8010449f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044a5:	8b 40 68             	mov    0x68(%eax),%eax
801044a8:	89 04 24             	mov    %eax,(%esp)
801044ab:	e8 22 d5 ff ff       	call   801019d2 <iput>
  proc->cwd = 0;
801044b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044b6:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801044bd:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801044c4:	e8 62 06 00 00       	call   80104b2b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801044c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044cf:	8b 40 14             	mov    0x14(%eax),%eax
801044d2:	89 04 24             	mov    %eax,(%esp)
801044d5:	e8 c4 03 00 00       	call   8010489e <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801044da:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
801044e1:	eb 3b                	jmp    8010451e <exit+0xf3>
    if(p->parent == proc){
801044e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e6:	8b 50 14             	mov    0x14(%eax),%edx
801044e9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801044ef:	39 c2                	cmp    %eax,%edx
801044f1:	75 24                	jne    80104517 <exit+0xec>
      p->parent = initproc;
801044f3:	8b 15 68 b6 10 80    	mov    0x8010b668,%edx
801044f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fc:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801044ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104502:	8b 40 0c             	mov    0xc(%eax),%eax
80104505:	83 f8 05             	cmp    $0x5,%eax
80104508:	75 0d                	jne    80104517 <exit+0xec>
        wakeup1(initproc);
8010450a:	a1 68 b6 10 80       	mov    0x8010b668,%eax
8010450f:	89 04 24             	mov    %eax,(%esp)
80104512:	e8 87 03 00 00       	call   8010489e <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104517:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
8010451e:	81 7d f4 74 22 11 80 	cmpl   $0x80112274,-0xc(%ebp)
80104525:	72 bc                	jb     801044e3 <exit+0xb8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104527:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010452d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104534:	e8 ba 01 00 00       	call   801046f3 <sched>
  panic("zombie exit");
80104539:	c7 04 24 b5 84 10 80 	movl   $0x801084b5,(%esp)
80104540:	e8 f1 bf ff ff       	call   80100536 <panic>

80104545 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104545:	55                   	push   %ebp
80104546:	89 e5                	mov    %esp,%ebp
80104548:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010454b:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104552:	e8 d4 05 00 00       	call   80104b2b <acquire>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104557:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010455e:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104565:	e9 9d 00 00 00       	jmp    80104607 <wait+0xc2>
      if(p->parent != proc)
8010456a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456d:	8b 50 14             	mov    0x14(%eax),%edx
80104570:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104576:	39 c2                	cmp    %eax,%edx
80104578:	0f 85 81 00 00 00    	jne    801045ff <wait+0xba>
        continue;
      havekids = 1;
8010457e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104588:	8b 40 0c             	mov    0xc(%eax),%eax
8010458b:	83 f8 05             	cmp    $0x5,%eax
8010458e:	75 70                	jne    80104600 <wait+0xbb>
        // Found one.
        pid = p->pid;
80104590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104593:	8b 40 10             	mov    0x10(%eax),%eax
80104596:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459c:	8b 40 08             	mov    0x8(%eax),%eax
8010459f:	89 04 24             	mov    %eax,(%esp)
801045a2:	e8 5f e4 ff ff       	call   80102a06 <kfree>
        p->kstack = 0;
801045a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045aa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801045b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b4:	8b 40 04             	mov    0x4(%eax),%eax
801045b7:	89 04 24             	mov    %eax,(%esp)
801045ba:	e8 ed 38 00 00       	call   80107eac <freevm>
        p->state = UNUSED;
801045bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c2:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
801045c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045cc:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801045d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801045dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e0:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801045e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e7:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
801045ee:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801045f5:	e8 93 05 00 00       	call   80104b8d <release>
        return pid;
801045fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045fd:	eb 56                	jmp    80104655 <wait+0x110>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
801045ff:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104600:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104607:	81 7d f4 74 22 11 80 	cmpl   $0x80112274,-0xc(%ebp)
8010460e:	0f 82 56 ff ff ff    	jb     8010456a <wait+0x25>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104614:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104618:	74 0d                	je     80104627 <wait+0xe2>
8010461a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104620:	8b 40 24             	mov    0x24(%eax),%eax
80104623:	85 c0                	test   %eax,%eax
80104625:	74 13                	je     8010463a <wait+0xf5>
      release(&ptable.lock);
80104627:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010462e:	e8 5a 05 00 00       	call   80104b8d <release>
      return -1;
80104633:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104638:	eb 1b                	jmp    80104655 <wait+0x110>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
8010463a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104640:	c7 44 24 04 40 ff 10 	movl   $0x8010ff40,0x4(%esp)
80104647:	80 
80104648:	89 04 24             	mov    %eax,(%esp)
8010464b:	e8 b3 01 00 00       	call   80104803 <sleep>
  }
80104650:	e9 02 ff ff ff       	jmp    80104557 <wait+0x12>
}
80104655:	c9                   	leave  
80104656:	c3                   	ret    

80104657 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104657:	55                   	push   %ebp
80104658:	89 e5                	mov    %esp,%ebp
8010465a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010465d:	e8 63 f9 ff ff       	call   80103fc5 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104662:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104669:	e8 bd 04 00 00       	call   80104b2b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010466e:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104675:	eb 62                	jmp    801046d9 <scheduler+0x82>
      if(p->state != RUNNABLE)
80104677:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467a:	8b 40 0c             	mov    0xc(%eax),%eax
8010467d:	83 f8 03             	cmp    $0x3,%eax
80104680:	75 4f                	jne    801046d1 <scheduler+0x7a>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104685:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
8010468b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468e:	89 04 24             	mov    %eax,(%esp)
80104691:	e8 ab 33 00 00       	call   80107a41 <switchuvm>
      p->state = RUNNING;
80104696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104699:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
801046a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046a6:	8b 40 1c             	mov    0x1c(%eax),%eax
801046a9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801046b0:	83 c2 04             	add    $0x4,%edx
801046b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801046b7:	89 14 24             	mov    %edx,(%esp)
801046ba:	e8 41 09 00 00       	call   80105000 <swtch>
      switchkvm();
801046bf:	e8 60 33 00 00       	call   80107a24 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
801046c4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801046cb:	00 00 00 00 
801046cf:	eb 01                	jmp    801046d2 <scheduler+0x7b>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
801046d1:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801046d2:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
801046d9:	81 7d f4 74 22 11 80 	cmpl   $0x80112274,-0xc(%ebp)
801046e0:	72 95                	jb     80104677 <scheduler+0x20>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
801046e2:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801046e9:	e8 9f 04 00 00       	call   80104b8d <release>

  }
801046ee:	e9 6a ff ff ff       	jmp    8010465d <scheduler+0x6>

801046f3 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801046f3:	55                   	push   %ebp
801046f4:	89 e5                	mov    %esp,%ebp
801046f6:	83 ec 28             	sub    $0x28,%esp
  int intena;

  if(!holding(&ptable.lock))
801046f9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104700:	e8 4e 05 00 00       	call   80104c53 <holding>
80104705:	85 c0                	test   %eax,%eax
80104707:	75 0c                	jne    80104715 <sched+0x22>
    panic("sched ptable.lock");
80104709:	c7 04 24 c1 84 10 80 	movl   $0x801084c1,(%esp)
80104710:	e8 21 be ff ff       	call   80100536 <panic>
  if(cpu->ncli != 1)
80104715:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010471b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104721:	83 f8 01             	cmp    $0x1,%eax
80104724:	74 0c                	je     80104732 <sched+0x3f>
    panic("sched locks");
80104726:	c7 04 24 d3 84 10 80 	movl   $0x801084d3,(%esp)
8010472d:	e8 04 be ff ff       	call   80100536 <panic>
  if(proc->state == RUNNING)
80104732:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104738:	8b 40 0c             	mov    0xc(%eax),%eax
8010473b:	83 f8 04             	cmp    $0x4,%eax
8010473e:	75 0c                	jne    8010474c <sched+0x59>
    panic("sched running");
80104740:	c7 04 24 df 84 10 80 	movl   $0x801084df,(%esp)
80104747:	e8 ea bd ff ff       	call   80100536 <panic>
  if(readeflags()&FL_IF)
8010474c:	e8 5f f8 ff ff       	call   80103fb0 <readeflags>
80104751:	25 00 02 00 00       	and    $0x200,%eax
80104756:	85 c0                	test   %eax,%eax
80104758:	74 0c                	je     80104766 <sched+0x73>
    panic("sched interruptible");
8010475a:	c7 04 24 ed 84 10 80 	movl   $0x801084ed,(%esp)
80104761:	e8 d0 bd ff ff       	call   80100536 <panic>
  intena = cpu->intena;
80104766:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010476c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104772:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104775:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010477b:	8b 40 04             	mov    0x4(%eax),%eax
8010477e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104785:	83 c2 1c             	add    $0x1c,%edx
80104788:	89 44 24 04          	mov    %eax,0x4(%esp)
8010478c:	89 14 24             	mov    %edx,(%esp)
8010478f:	e8 6c 08 00 00       	call   80105000 <swtch>
  cpu->intena = intena;
80104794:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010479a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010479d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801047a3:	c9                   	leave  
801047a4:	c3                   	ret    

801047a5 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
801047a5:	55                   	push   %ebp
801047a6:	89 e5                	mov    %esp,%ebp
801047a8:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801047ab:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801047b2:	e8 74 03 00 00       	call   80104b2b <acquire>
  proc->state = RUNNABLE;
801047b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047bd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801047c4:	e8 2a ff ff ff       	call   801046f3 <sched>
  release(&ptable.lock);
801047c9:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801047d0:	e8 b8 03 00 00       	call   80104b8d <release>
}
801047d5:	c9                   	leave  
801047d6:	c3                   	ret    

801047d7 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801047d7:	55                   	push   %ebp
801047d8:	89 e5                	mov    %esp,%ebp
801047da:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801047dd:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801047e4:	e8 a4 03 00 00       	call   80104b8d <release>

  if (first) {
801047e9:	a1 20 b0 10 80       	mov    0x8010b020,%eax
801047ee:	85 c0                	test   %eax,%eax
801047f0:	74 0f                	je     80104801 <forkret+0x2a>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801047f2:	c7 05 20 b0 10 80 00 	movl   $0x0,0x8010b020
801047f9:	00 00 00 
    initlog();
801047fc:	e8 a3 e7 ff ff       	call   80102fa4 <initlog>
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104801:	c9                   	leave  
80104802:	c3                   	ret    

80104803 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104803:	55                   	push   %ebp
80104804:	89 e5                	mov    %esp,%ebp
80104806:	83 ec 18             	sub    $0x18,%esp
  if(proc == 0)
80104809:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010480f:	85 c0                	test   %eax,%eax
80104811:	75 0c                	jne    8010481f <sleep+0x1c>
    panic("sleep");
80104813:	c7 04 24 01 85 10 80 	movl   $0x80108501,(%esp)
8010481a:	e8 17 bd ff ff       	call   80100536 <panic>

  if(lk == 0)
8010481f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104823:	75 0c                	jne    80104831 <sleep+0x2e>
    panic("sleep without lk");
80104825:	c7 04 24 07 85 10 80 	movl   $0x80108507,(%esp)
8010482c:	e8 05 bd ff ff       	call   80100536 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104831:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104838:	74 17                	je     80104851 <sleep+0x4e>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010483a:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104841:	e8 e5 02 00 00       	call   80104b2b <acquire>
    release(lk);
80104846:	8b 45 0c             	mov    0xc(%ebp),%eax
80104849:	89 04 24             	mov    %eax,(%esp)
8010484c:	e8 3c 03 00 00       	call   80104b8d <release>
  }

  // Go to sleep.
  proc->chan = chan;
80104851:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104857:	8b 55 08             	mov    0x8(%ebp),%edx
8010485a:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010485d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104863:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
8010486a:	e8 84 fe ff ff       	call   801046f3 <sched>

  // Tidy up.
  proc->chan = 0;
8010486f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104875:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010487c:	81 7d 0c 40 ff 10 80 	cmpl   $0x8010ff40,0xc(%ebp)
80104883:	74 17                	je     8010489c <sleep+0x99>
    release(&ptable.lock);
80104885:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
8010488c:	e8 fc 02 00 00       	call   80104b8d <release>
    acquire(lk);
80104891:	8b 45 0c             	mov    0xc(%ebp),%eax
80104894:	89 04 24             	mov    %eax,(%esp)
80104897:	e8 8f 02 00 00       	call   80104b2b <acquire>
  }
}
8010489c:	c9                   	leave  
8010489d:	c3                   	ret    

8010489e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010489e:	55                   	push   %ebp
8010489f:	89 e5                	mov    %esp,%ebp
801048a1:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048a4:	c7 45 fc 74 ff 10 80 	movl   $0x8010ff74,-0x4(%ebp)
801048ab:	eb 27                	jmp    801048d4 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
801048ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048b0:	8b 40 0c             	mov    0xc(%eax),%eax
801048b3:	83 f8 02             	cmp    $0x2,%eax
801048b6:	75 15                	jne    801048cd <wakeup1+0x2f>
801048b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048bb:	8b 40 20             	mov    0x20(%eax),%eax
801048be:	3b 45 08             	cmp    0x8(%ebp),%eax
801048c1:	75 0a                	jne    801048cd <wakeup1+0x2f>
      p->state = RUNNABLE;
801048c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801048c6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801048cd:	81 45 fc 8c 00 00 00 	addl   $0x8c,-0x4(%ebp)
801048d4:	81 7d fc 74 22 11 80 	cmpl   $0x80112274,-0x4(%ebp)
801048db:	72 d0                	jb     801048ad <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
801048dd:	c9                   	leave  
801048de:	c3                   	ret    

801048df <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801048df:	55                   	push   %ebp
801048e0:	89 e5                	mov    %esp,%ebp
801048e2:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
801048e5:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
801048ec:	e8 3a 02 00 00       	call   80104b2b <acquire>
  wakeup1(chan);
801048f1:	8b 45 08             	mov    0x8(%ebp),%eax
801048f4:	89 04 24             	mov    %eax,(%esp)
801048f7:	e8 a2 ff ff ff       	call   8010489e <wakeup1>
  release(&ptable.lock);
801048fc:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104903:	e8 85 02 00 00       	call   80104b8d <release>
}
80104908:	c9                   	leave  
80104909:	c3                   	ret    

8010490a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010490a:	55                   	push   %ebp
8010490b:	89 e5                	mov    %esp,%ebp
8010490d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104910:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104917:	e8 0f 02 00 00       	call   80104b2b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010491c:	c7 45 f4 74 ff 10 80 	movl   $0x8010ff74,-0xc(%ebp)
80104923:	eb 44                	jmp    80104969 <kill+0x5f>
    if(p->pid == pid){
80104925:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104928:	8b 40 10             	mov    0x10(%eax),%eax
8010492b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010492e:	75 32                	jne    80104962 <kill+0x58>
      p->killed = 1;
80104930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104933:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010493a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010493d:	8b 40 0c             	mov    0xc(%eax),%eax
80104940:	83 f8 02             	cmp    $0x2,%eax
80104943:	75 0a                	jne    8010494f <kill+0x45>
        p->state = RUNNABLE;
80104945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104948:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010494f:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104956:	e8 32 02 00 00       	call   80104b8d <release>
      return 0;
8010495b:	b8 00 00 00 00       	mov    $0x0,%eax
80104960:	eb 21                	jmp    80104983 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104962:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104969:	81 7d f4 74 22 11 80 	cmpl   $0x80112274,-0xc(%ebp)
80104970:	72 b3                	jb     80104925 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104972:	c7 04 24 40 ff 10 80 	movl   $0x8010ff40,(%esp)
80104979:	e8 0f 02 00 00       	call   80104b8d <release>
  return -1;
8010497e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104983:	c9                   	leave  
80104984:	c3                   	ret    

80104985 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104985:	55                   	push   %ebp
80104986:	89 e5                	mov    %esp,%ebp
80104988:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010498b:	c7 45 f0 74 ff 10 80 	movl   $0x8010ff74,-0x10(%ebp)
80104992:	e9 da 00 00 00       	jmp    80104a71 <procdump+0xec>
    if(p->state == UNUSED)
80104997:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499a:	8b 40 0c             	mov    0xc(%eax),%eax
8010499d:	85 c0                	test   %eax,%eax
8010499f:	0f 84 c4 00 00 00    	je     80104a69 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801049a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049a8:	8b 40 0c             	mov    0xc(%eax),%eax
801049ab:	83 f8 05             	cmp    $0x5,%eax
801049ae:	77 23                	ja     801049d3 <procdump+0x4e>
801049b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049b3:	8b 40 0c             	mov    0xc(%eax),%eax
801049b6:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
801049bd:	85 c0                	test   %eax,%eax
801049bf:	74 12                	je     801049d3 <procdump+0x4e>
      state = states[p->state];
801049c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049c4:	8b 40 0c             	mov    0xc(%eax),%eax
801049c7:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
801049ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
801049d1:	eb 07                	jmp    801049da <procdump+0x55>
    else
      state = "???";
801049d3:	c7 45 ec 18 85 10 80 	movl   $0x80108518,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801049da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049dd:	8d 50 6c             	lea    0x6c(%eax),%edx
801049e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049e3:	8b 40 10             	mov    0x10(%eax),%eax
801049e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
801049ea:	8b 55 ec             	mov    -0x14(%ebp),%edx
801049ed:	89 54 24 08          	mov    %edx,0x8(%esp)
801049f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801049f5:	c7 04 24 1c 85 10 80 	movl   $0x8010851c,(%esp)
801049fc:	e8 a0 b9 ff ff       	call   801003a1 <cprintf>
    if(p->state == SLEEPING){
80104a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a04:	8b 40 0c             	mov    0xc(%eax),%eax
80104a07:	83 f8 02             	cmp    $0x2,%eax
80104a0a:	75 4f                	jne    80104a5b <procdump+0xd6>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a0f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104a12:	8b 40 0c             	mov    0xc(%eax),%eax
80104a15:	83 c0 08             	add    $0x8,%eax
80104a18:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104a1b:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a1f:	89 04 24             	mov    %eax,(%esp)
80104a22:	e8 b5 01 00 00       	call   80104bdc <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104a27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a2e:	eb 1a                	jmp    80104a4a <procdump+0xc5>
        cprintf(" %p", pc[i]);
80104a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a33:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a37:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a3b:	c7 04 24 25 85 10 80 	movl   $0x80108525,(%esp)
80104a42:	e8 5a b9 ff ff       	call   801003a1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104a47:	ff 45 f4             	incl   -0xc(%ebp)
80104a4a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104a4e:	7f 0b                	jg     80104a5b <procdump+0xd6>
80104a50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a53:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104a57:	85 c0                	test   %eax,%eax
80104a59:	75 d5                	jne    80104a30 <procdump+0xab>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104a5b:	c7 04 24 29 85 10 80 	movl   $0x80108529,(%esp)
80104a62:	e8 3a b9 ff ff       	call   801003a1 <cprintf>
80104a67:	eb 01                	jmp    80104a6a <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80104a69:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6a:	81 45 f0 8c 00 00 00 	addl   $0x8c,-0x10(%ebp)
80104a71:	81 7d f0 74 22 11 80 	cmpl   $0x80112274,-0x10(%ebp)
80104a78:	0f 82 19 ff ff ff    	jb     80104997 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104a7e:	c9                   	leave  
80104a7f:	c3                   	ret    

80104a80 <signal>:

int
signal(int signum, sighandler_t signal_handler)
{
80104a80:	55                   	push   %ebp
80104a81:	89 e5                	mov    %esp,%ebp
    if((signum != 0) && (signum != 1))
80104a83:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104a87:	74 0d                	je     80104a96 <signal+0x16>
80104a89:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104a8d:	74 07                	je     80104a96 <signal+0x16>
        return -1;
80104a8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a94:	eb 2b                	jmp    80104ac1 <signal+0x41>
    else
    {
      proc->sig_flag[signum] = signum;
80104a96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a9c:	8b 55 08             	mov    0x8(%ebp),%edx
80104a9f:	8d 4a 20             	lea    0x20(%edx),%ecx
80104aa2:	8b 55 08             	mov    0x8(%ebp),%edx
80104aa5:	89 54 88 04          	mov    %edx,0x4(%eax,%ecx,4)
      proc->signal_handler[signum] = signal_handler;
80104aa9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aaf:	8b 55 08             	mov    0x8(%ebp),%edx
80104ab2:	8d 4a 1c             	lea    0x1c(%edx),%ecx
80104ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ab8:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      return 1;
80104abc:	b8 01 00 00 00       	mov    $0x1,%eax
    }
80104ac1:	5d                   	pop    %ebp
80104ac2:	c3                   	ret    
80104ac3:	90                   	nop

80104ac4 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104ac4:	55                   	push   %ebp
80104ac5:	89 e5                	mov    %esp,%ebp
80104ac7:	53                   	push   %ebx
80104ac8:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104acb:	9c                   	pushf  
80104acc:	5b                   	pop    %ebx
80104acd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return eflags;
80104ad0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104ad3:	83 c4 10             	add    $0x10,%esp
80104ad6:	5b                   	pop    %ebx
80104ad7:	5d                   	pop    %ebp
80104ad8:	c3                   	ret    

80104ad9 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80104ad9:	55                   	push   %ebp
80104ada:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104adc:	fa                   	cli    
}
80104add:	5d                   	pop    %ebp
80104ade:	c3                   	ret    

80104adf <sti>:

static inline void
sti(void)
{
80104adf:	55                   	push   %ebp
80104ae0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ae2:	fb                   	sti    
}
80104ae3:	5d                   	pop    %ebp
80104ae4:	c3                   	ret    

80104ae5 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104ae5:	55                   	push   %ebp
80104ae6:	89 e5                	mov    %esp,%ebp
80104ae8:	53                   	push   %ebx
80104ae9:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
80104aec:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104aef:	8b 45 0c             	mov    0xc(%ebp),%eax
               "+m" (*addr), "=a" (result) :
80104af2:	8b 4d 08             	mov    0x8(%ebp),%ecx
xchg(volatile uint *addr, uint newval)
{
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104af5:	89 c3                	mov    %eax,%ebx
80104af7:	89 d8                	mov    %ebx,%eax
80104af9:	f0 87 02             	lock xchg %eax,(%edx)
80104afc:	89 c3                	mov    %eax,%ebx
80104afe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104b01:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80104b04:	83 c4 10             	add    $0x10,%esp
80104b07:	5b                   	pop    %ebx
80104b08:	5d                   	pop    %ebp
80104b09:	c3                   	ret    

80104b0a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104b0a:	55                   	push   %ebp
80104b0b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80104b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b10:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b13:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104b16:	8b 45 08             	mov    0x8(%ebp),%eax
80104b19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b22:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104b29:	5d                   	pop    %ebp
80104b2a:	c3                   	ret    

80104b2b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104b2b:	55                   	push   %ebp
80104b2c:	89 e5                	mov    %esp,%ebp
80104b2e:	83 ec 18             	sub    $0x18,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b31:	e8 47 01 00 00       	call   80104c7d <pushcli>
  if(holding(lk))
80104b36:	8b 45 08             	mov    0x8(%ebp),%eax
80104b39:	89 04 24             	mov    %eax,(%esp)
80104b3c:	e8 12 01 00 00       	call   80104c53 <holding>
80104b41:	85 c0                	test   %eax,%eax
80104b43:	74 0c                	je     80104b51 <acquire+0x26>
    panic("acquire");
80104b45:	c7 04 24 55 85 10 80 	movl   $0x80108555,(%esp)
80104b4c:	e8 e5 b9 ff ff       	call   80100536 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80104b51:	90                   	nop
80104b52:	8b 45 08             	mov    0x8(%ebp),%eax
80104b55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104b5c:	00 
80104b5d:	89 04 24             	mov    %eax,(%esp)
80104b60:	e8 80 ff ff ff       	call   80104ae5 <xchg>
80104b65:	85 c0                	test   %eax,%eax
80104b67:	75 e9                	jne    80104b52 <acquire+0x27>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80104b69:	8b 45 08             	mov    0x8(%ebp),%eax
80104b6c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104b73:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80104b76:	8b 45 08             	mov    0x8(%ebp),%eax
80104b79:	83 c0 0c             	add    $0xc,%eax
80104b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b80:	8d 45 08             	lea    0x8(%ebp),%eax
80104b83:	89 04 24             	mov    %eax,(%esp)
80104b86:	e8 51 00 00 00       	call   80104bdc <getcallerpcs>
}
80104b8b:	c9                   	leave  
80104b8c:	c3                   	ret    

80104b8d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104b8d:	55                   	push   %ebp
80104b8e:	89 e5                	mov    %esp,%ebp
80104b90:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80104b93:	8b 45 08             	mov    0x8(%ebp),%eax
80104b96:	89 04 24             	mov    %eax,(%esp)
80104b99:	e8 b5 00 00 00       	call   80104c53 <holding>
80104b9e:	85 c0                	test   %eax,%eax
80104ba0:	75 0c                	jne    80104bae <release+0x21>
    panic("release");
80104ba2:	c7 04 24 5d 85 10 80 	movl   $0x8010855d,(%esp)
80104ba9:	e8 88 b9 ff ff       	call   80100536 <panic>

  lk->pcs[0] = 0;
80104bae:	8b 45 08             	mov    0x8(%ebp),%eax
80104bb1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80104bb8:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80104bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80104bc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104bcc:	00 
80104bcd:	89 04 24             	mov    %eax,(%esp)
80104bd0:	e8 10 ff ff ff       	call   80104ae5 <xchg>

  popcli();
80104bd5:	e8 e9 00 00 00       	call   80104cc3 <popcli>
}
80104bda:	c9                   	leave  
80104bdb:	c3                   	ret    

80104bdc <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104bdc:	55                   	push   %ebp
80104bdd:	89 e5                	mov    %esp,%ebp
80104bdf:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80104be2:	8b 45 08             	mov    0x8(%ebp),%eax
80104be5:	83 e8 08             	sub    $0x8,%eax
80104be8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104beb:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80104bf2:	eb 37                	jmp    80104c2b <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bf4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104bf8:	74 51                	je     80104c4b <getcallerpcs+0x6f>
80104bfa:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80104c01:	76 48                	jbe    80104c4b <getcallerpcs+0x6f>
80104c03:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104c07:	74 42                	je     80104c4b <getcallerpcs+0x6f>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104c09:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c0c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c13:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c16:	01 c2                	add    %eax,%edx
80104c18:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c1b:	8b 40 04             	mov    0x4(%eax),%eax
80104c1e:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80104c20:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c23:	8b 00                	mov    (%eax),%eax
80104c25:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104c28:	ff 45 f8             	incl   -0x8(%ebp)
80104c2b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c2f:	7e c3                	jle    80104bf4 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104c31:	eb 18                	jmp    80104c4b <getcallerpcs+0x6f>
    pcs[i] = 0;
80104c33:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104c36:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c40:	01 d0                	add    %edx,%eax
80104c42:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80104c48:	ff 45 f8             	incl   -0x8(%ebp)
80104c4b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104c4f:	7e e2                	jle    80104c33 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80104c51:	c9                   	leave  
80104c52:	c3                   	ret    

80104c53 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104c53:	55                   	push   %ebp
80104c54:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80104c56:	8b 45 08             	mov    0x8(%ebp),%eax
80104c59:	8b 00                	mov    (%eax),%eax
80104c5b:	85 c0                	test   %eax,%eax
80104c5d:	74 17                	je     80104c76 <holding+0x23>
80104c5f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c62:	8b 50 08             	mov    0x8(%eax),%edx
80104c65:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c6b:	39 c2                	cmp    %eax,%edx
80104c6d:	75 07                	jne    80104c76 <holding+0x23>
80104c6f:	b8 01 00 00 00       	mov    $0x1,%eax
80104c74:	eb 05                	jmp    80104c7b <holding+0x28>
80104c76:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c7b:	5d                   	pop    %ebp
80104c7c:	c3                   	ret    

80104c7d <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104c7d:	55                   	push   %ebp
80104c7e:	89 e5                	mov    %esp,%ebp
80104c80:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80104c83:	e8 3c fe ff ff       	call   80104ac4 <readeflags>
80104c88:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80104c8b:	e8 49 fe ff ff       	call   80104ad9 <cli>
  if(cpu->ncli++ == 0)
80104c90:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c96:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104c9c:	85 d2                	test   %edx,%edx
80104c9e:	0f 94 c1             	sete   %cl
80104ca1:	42                   	inc    %edx
80104ca2:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104ca8:	84 c9                	test   %cl,%cl
80104caa:	74 15                	je     80104cc1 <pushcli+0x44>
    cpu->intena = eflags & FL_IF;
80104cac:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cb2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104cb5:	81 e2 00 02 00 00    	and    $0x200,%edx
80104cbb:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cc1:	c9                   	leave  
80104cc2:	c3                   	ret    

80104cc3 <popcli>:

void
popcli(void)
{
80104cc3:	55                   	push   %ebp
80104cc4:	89 e5                	mov    %esp,%ebp
80104cc6:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80104cc9:	e8 f6 fd ff ff       	call   80104ac4 <readeflags>
80104cce:	25 00 02 00 00       	and    $0x200,%eax
80104cd3:	85 c0                	test   %eax,%eax
80104cd5:	74 0c                	je     80104ce3 <popcli+0x20>
    panic("popcli - interruptible");
80104cd7:	c7 04 24 65 85 10 80 	movl   $0x80108565,(%esp)
80104cde:	e8 53 b8 ff ff       	call   80100536 <panic>
  if(--cpu->ncli < 0)
80104ce3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ce9:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80104cef:	4a                   	dec    %edx
80104cf0:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80104cf6:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104cfc:	85 c0                	test   %eax,%eax
80104cfe:	79 0c                	jns    80104d0c <popcli+0x49>
    panic("popcli");
80104d00:	c7 04 24 7c 85 10 80 	movl   $0x8010857c,(%esp)
80104d07:	e8 2a b8 ff ff       	call   80100536 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80104d0c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d12:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d18:	85 c0                	test   %eax,%eax
80104d1a:	75 15                	jne    80104d31 <popcli+0x6e>
80104d1c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d22:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d28:	85 c0                	test   %eax,%eax
80104d2a:	74 05                	je     80104d31 <popcli+0x6e>
    sti();
80104d2c:	e8 ae fd ff ff       	call   80104adf <sti>
}
80104d31:	c9                   	leave  
80104d32:	c3                   	ret    
80104d33:	90                   	nop

80104d34 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80104d34:	55                   	push   %ebp
80104d35:	89 e5                	mov    %esp,%ebp
80104d37:	57                   	push   %edi
80104d38:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104d39:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d3c:	8b 55 10             	mov    0x10(%ebp),%edx
80104d3f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d42:	89 cb                	mov    %ecx,%ebx
80104d44:	89 df                	mov    %ebx,%edi
80104d46:	89 d1                	mov    %edx,%ecx
80104d48:	fc                   	cld    
80104d49:	f3 aa                	rep stos %al,%es:(%edi)
80104d4b:	89 ca                	mov    %ecx,%edx
80104d4d:	89 fb                	mov    %edi,%ebx
80104d4f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d52:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104d55:	5b                   	pop    %ebx
80104d56:	5f                   	pop    %edi
80104d57:	5d                   	pop    %ebp
80104d58:	c3                   	ret    

80104d59 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80104d59:	55                   	push   %ebp
80104d5a:	89 e5                	mov    %esp,%ebp
80104d5c:	57                   	push   %edi
80104d5d:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104d5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d61:	8b 55 10             	mov    0x10(%ebp),%edx
80104d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d67:	89 cb                	mov    %ecx,%ebx
80104d69:	89 df                	mov    %ebx,%edi
80104d6b:	89 d1                	mov    %edx,%ecx
80104d6d:	fc                   	cld    
80104d6e:	f3 ab                	rep stos %eax,%es:(%edi)
80104d70:	89 ca                	mov    %ecx,%edx
80104d72:	89 fb                	mov    %edi,%ebx
80104d74:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104d77:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80104d7a:	5b                   	pop    %ebx
80104d7b:	5f                   	pop    %edi
80104d7c:	5d                   	pop    %ebp
80104d7d:	c3                   	ret    

80104d7e <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104d7e:	55                   	push   %ebp
80104d7f:	89 e5                	mov    %esp,%ebp
80104d81:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80104d84:	8b 45 08             	mov    0x8(%ebp),%eax
80104d87:	83 e0 03             	and    $0x3,%eax
80104d8a:	85 c0                	test   %eax,%eax
80104d8c:	75 49                	jne    80104dd7 <memset+0x59>
80104d8e:	8b 45 10             	mov    0x10(%ebp),%eax
80104d91:	83 e0 03             	and    $0x3,%eax
80104d94:	85 c0                	test   %eax,%eax
80104d96:	75 3f                	jne    80104dd7 <memset+0x59>
    c &= 0xFF;
80104d98:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104d9f:	8b 45 10             	mov    0x10(%ebp),%eax
80104da2:	c1 e8 02             	shr    $0x2,%eax
80104da5:	89 c2                	mov    %eax,%edx
80104da7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104daa:	89 c1                	mov    %eax,%ecx
80104dac:	c1 e1 18             	shl    $0x18,%ecx
80104daf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104db2:	c1 e0 10             	shl    $0x10,%eax
80104db5:	09 c1                	or     %eax,%ecx
80104db7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104dba:	c1 e0 08             	shl    $0x8,%eax
80104dbd:	09 c8                	or     %ecx,%eax
80104dbf:	0b 45 0c             	or     0xc(%ebp),%eax
80104dc2:	89 54 24 08          	mov    %edx,0x8(%esp)
80104dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dca:	8b 45 08             	mov    0x8(%ebp),%eax
80104dcd:	89 04 24             	mov    %eax,(%esp)
80104dd0:	e8 84 ff ff ff       	call   80104d59 <stosl>
80104dd5:	eb 19                	jmp    80104df0 <memset+0x72>
  } else
    stosb(dst, c, n);
80104dd7:	8b 45 10             	mov    0x10(%ebp),%eax
80104dda:	89 44 24 08          	mov    %eax,0x8(%esp)
80104dde:	8b 45 0c             	mov    0xc(%ebp),%eax
80104de1:	89 44 24 04          	mov    %eax,0x4(%esp)
80104de5:	8b 45 08             	mov    0x8(%ebp),%eax
80104de8:	89 04 24             	mov    %eax,(%esp)
80104deb:	e8 44 ff ff ff       	call   80104d34 <stosb>
  return dst;
80104df0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104df3:	c9                   	leave  
80104df4:	c3                   	ret    

80104df5 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104df5:	55                   	push   %ebp
80104df6:	89 e5                	mov    %esp,%ebp
80104df8:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80104dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dfe:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104e01:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e04:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104e07:	eb 2c                	jmp    80104e35 <memcmp+0x40>
    if(*s1 != *s2)
80104e09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e0c:	8a 10                	mov    (%eax),%dl
80104e0e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e11:	8a 00                	mov    (%eax),%al
80104e13:	38 c2                	cmp    %al,%dl
80104e15:	74 18                	je     80104e2f <memcmp+0x3a>
      return *s1 - *s2;
80104e17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e1a:	8a 00                	mov    (%eax),%al
80104e1c:	0f b6 d0             	movzbl %al,%edx
80104e1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e22:	8a 00                	mov    (%eax),%al
80104e24:	0f b6 c0             	movzbl %al,%eax
80104e27:	89 d1                	mov    %edx,%ecx
80104e29:	29 c1                	sub    %eax,%ecx
80104e2b:	89 c8                	mov    %ecx,%eax
80104e2d:	eb 19                	jmp    80104e48 <memcmp+0x53>
    s1++, s2++;
80104e2f:	ff 45 fc             	incl   -0x4(%ebp)
80104e32:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104e35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e39:	0f 95 c0             	setne  %al
80104e3c:	ff 4d 10             	decl   0x10(%ebp)
80104e3f:	84 c0                	test   %al,%al
80104e41:	75 c6                	jne    80104e09 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80104e43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e48:	c9                   	leave  
80104e49:	c3                   	ret    

80104e4a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104e4a:	55                   	push   %ebp
80104e4b:	89 e5                	mov    %esp,%ebp
80104e4d:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e53:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104e56:	8b 45 08             	mov    0x8(%ebp),%eax
80104e59:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104e5c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e5f:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e62:	73 4d                	jae    80104eb1 <memmove+0x67>
80104e64:	8b 45 10             	mov    0x10(%ebp),%eax
80104e67:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104e6a:	01 d0                	add    %edx,%eax
80104e6c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104e6f:	76 40                	jbe    80104eb1 <memmove+0x67>
    s += n;
80104e71:	8b 45 10             	mov    0x10(%ebp),%eax
80104e74:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104e77:	8b 45 10             	mov    0x10(%ebp),%eax
80104e7a:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104e7d:	eb 10                	jmp    80104e8f <memmove+0x45>
      *--d = *--s;
80104e7f:	ff 4d f8             	decl   -0x8(%ebp)
80104e82:	ff 4d fc             	decl   -0x4(%ebp)
80104e85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e88:	8a 10                	mov    (%eax),%dl
80104e8a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104e8d:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80104e8f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e93:	0f 95 c0             	setne  %al
80104e96:	ff 4d 10             	decl   0x10(%ebp)
80104e99:	84 c0                	test   %al,%al
80104e9b:	75 e2                	jne    80104e7f <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104e9d:	eb 21                	jmp    80104ec0 <memmove+0x76>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80104e9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ea2:	8a 10                	mov    (%eax),%dl
80104ea4:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ea7:	88 10                	mov    %dl,(%eax)
80104ea9:	ff 45 f8             	incl   -0x8(%ebp)
80104eac:	ff 45 fc             	incl   -0x4(%ebp)
80104eaf:	eb 01                	jmp    80104eb2 <memmove+0x68>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80104eb1:	90                   	nop
80104eb2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104eb6:	0f 95 c0             	setne  %al
80104eb9:	ff 4d 10             	decl   0x10(%ebp)
80104ebc:	84 c0                	test   %al,%al
80104ebe:	75 df                	jne    80104e9f <memmove+0x55>
      *d++ = *s++;

  return dst;
80104ec0:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ec3:	c9                   	leave  
80104ec4:	c3                   	ret    

80104ec5 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104ec5:	55                   	push   %ebp
80104ec6:	89 e5                	mov    %esp,%ebp
80104ec8:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80104ecb:	8b 45 10             	mov    0x10(%ebp),%eax
80104ece:	89 44 24 08          	mov    %eax,0x8(%esp)
80104ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ed9:	8b 45 08             	mov    0x8(%ebp),%eax
80104edc:	89 04 24             	mov    %eax,(%esp)
80104edf:	e8 66 ff ff ff       	call   80104e4a <memmove>
}
80104ee4:	c9                   	leave  
80104ee5:	c3                   	ret    

80104ee6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ee9:	eb 09                	jmp    80104ef4 <strncmp+0xe>
    n--, p++, q++;
80104eeb:	ff 4d 10             	decl   0x10(%ebp)
80104eee:	ff 45 08             	incl   0x8(%ebp)
80104ef1:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80104ef4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ef8:	74 17                	je     80104f11 <strncmp+0x2b>
80104efa:	8b 45 08             	mov    0x8(%ebp),%eax
80104efd:	8a 00                	mov    (%eax),%al
80104eff:	84 c0                	test   %al,%al
80104f01:	74 0e                	je     80104f11 <strncmp+0x2b>
80104f03:	8b 45 08             	mov    0x8(%ebp),%eax
80104f06:	8a 10                	mov    (%eax),%dl
80104f08:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f0b:	8a 00                	mov    (%eax),%al
80104f0d:	38 c2                	cmp    %al,%dl
80104f0f:	74 da                	je     80104eeb <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80104f11:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f15:	75 07                	jne    80104f1e <strncmp+0x38>
    return 0;
80104f17:	b8 00 00 00 00       	mov    $0x0,%eax
80104f1c:	eb 16                	jmp    80104f34 <strncmp+0x4e>
  return (uchar)*p - (uchar)*q;
80104f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80104f21:	8a 00                	mov    (%eax),%al
80104f23:	0f b6 d0             	movzbl %al,%edx
80104f26:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f29:	8a 00                	mov    (%eax),%al
80104f2b:	0f b6 c0             	movzbl %al,%eax
80104f2e:	89 d1                	mov    %edx,%ecx
80104f30:	29 c1                	sub    %eax,%ecx
80104f32:	89 c8                	mov    %ecx,%eax
}
80104f34:	5d                   	pop    %ebp
80104f35:	c3                   	ret    

80104f36 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104f36:	55                   	push   %ebp
80104f37:	89 e5                	mov    %esp,%ebp
80104f39:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104f3f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104f42:	90                   	nop
80104f43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f47:	0f 9f c0             	setg   %al
80104f4a:	ff 4d 10             	decl   0x10(%ebp)
80104f4d:	84 c0                	test   %al,%al
80104f4f:	74 2b                	je     80104f7c <strncpy+0x46>
80104f51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f54:	8a 10                	mov    (%eax),%dl
80104f56:	8b 45 08             	mov    0x8(%ebp),%eax
80104f59:	88 10                	mov    %dl,(%eax)
80104f5b:	8b 45 08             	mov    0x8(%ebp),%eax
80104f5e:	8a 00                	mov    (%eax),%al
80104f60:	84 c0                	test   %al,%al
80104f62:	0f 95 c0             	setne  %al
80104f65:	ff 45 08             	incl   0x8(%ebp)
80104f68:	ff 45 0c             	incl   0xc(%ebp)
80104f6b:	84 c0                	test   %al,%al
80104f6d:	75 d4                	jne    80104f43 <strncpy+0xd>
    ;
  while(n-- > 0)
80104f6f:	eb 0b                	jmp    80104f7c <strncpy+0x46>
    *s++ = 0;
80104f71:	8b 45 08             	mov    0x8(%ebp),%eax
80104f74:	c6 00 00             	movb   $0x0,(%eax)
80104f77:	ff 45 08             	incl   0x8(%ebp)
80104f7a:	eb 01                	jmp    80104f7d <strncpy+0x47>
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80104f7c:	90                   	nop
80104f7d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f81:	0f 9f c0             	setg   %al
80104f84:	ff 4d 10             	decl   0x10(%ebp)
80104f87:	84 c0                	test   %al,%al
80104f89:	75 e6                	jne    80104f71 <strncpy+0x3b>
    *s++ = 0;
  return os;
80104f8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104f8e:	c9                   	leave  
80104f8f:	c3                   	ret    

80104f90 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104f90:	55                   	push   %ebp
80104f91:	89 e5                	mov    %esp,%ebp
80104f93:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80104f96:	8b 45 08             	mov    0x8(%ebp),%eax
80104f99:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104f9c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fa0:	7f 05                	jg     80104fa7 <safestrcpy+0x17>
    return os;
80104fa2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fa5:	eb 30                	jmp    80104fd7 <safestrcpy+0x47>
  while(--n > 0 && (*s++ = *t++) != 0)
80104fa7:	ff 4d 10             	decl   0x10(%ebp)
80104faa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104fae:	7e 1e                	jle    80104fce <safestrcpy+0x3e>
80104fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104fb3:	8a 10                	mov    (%eax),%dl
80104fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80104fb8:	88 10                	mov    %dl,(%eax)
80104fba:	8b 45 08             	mov    0x8(%ebp),%eax
80104fbd:	8a 00                	mov    (%eax),%al
80104fbf:	84 c0                	test   %al,%al
80104fc1:	0f 95 c0             	setne  %al
80104fc4:	ff 45 08             	incl   0x8(%ebp)
80104fc7:	ff 45 0c             	incl   0xc(%ebp)
80104fca:	84 c0                	test   %al,%al
80104fcc:	75 d9                	jne    80104fa7 <safestrcpy+0x17>
    ;
  *s = 0;
80104fce:	8b 45 08             	mov    0x8(%ebp),%eax
80104fd1:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104fd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104fd7:	c9                   	leave  
80104fd8:	c3                   	ret    

80104fd9 <strlen>:

int
strlen(const char *s)
{
80104fd9:	55                   	push   %ebp
80104fda:	89 e5                	mov    %esp,%ebp
80104fdc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104fdf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104fe6:	eb 03                	jmp    80104feb <strlen+0x12>
80104fe8:	ff 45 fc             	incl   -0x4(%ebp)
80104feb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104fee:	8b 45 08             	mov    0x8(%ebp),%eax
80104ff1:	01 d0                	add    %edx,%eax
80104ff3:	8a 00                	mov    (%eax),%al
80104ff5:	84 c0                	test   %al,%al
80104ff7:	75 ef                	jne    80104fe8 <strlen+0xf>
    ;
  return n;
80104ff9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ffc:	c9                   	leave  
80104ffd:	c3                   	ret    
80104ffe:	66 90                	xchg   %ax,%ax

80105000 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105000:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105004:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105008:	55                   	push   %ebp
  pushl %ebx
80105009:	53                   	push   %ebx
  pushl %esi
8010500a:	56                   	push   %esi
  pushl %edi
8010500b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010500c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010500e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105010:	5f                   	pop    %edi
  popl %esi
80105011:	5e                   	pop    %esi
  popl %ebx
80105012:	5b                   	pop    %ebx
  popl %ebp
80105013:	5d                   	pop    %ebp
  ret
80105014:	c3                   	ret    
80105015:	66 90                	xchg   %ax,%ax
80105017:	90                   	nop

80105018 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105018:	55                   	push   %ebp
80105019:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010501b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105021:	8b 00                	mov    (%eax),%eax
80105023:	3b 45 08             	cmp    0x8(%ebp),%eax
80105026:	76 12                	jbe    8010503a <fetchint+0x22>
80105028:	8b 45 08             	mov    0x8(%ebp),%eax
8010502b:	8d 50 04             	lea    0x4(%eax),%edx
8010502e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105034:	8b 00                	mov    (%eax),%eax
80105036:	39 c2                	cmp    %eax,%edx
80105038:	76 07                	jbe    80105041 <fetchint+0x29>
    return -1;
8010503a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010503f:	eb 0f                	jmp    80105050 <fetchint+0x38>
  *ip = *(int*)(addr);
80105041:	8b 45 08             	mov    0x8(%ebp),%eax
80105044:	8b 10                	mov    (%eax),%edx
80105046:	8b 45 0c             	mov    0xc(%ebp),%eax
80105049:	89 10                	mov    %edx,(%eax)
  return 0;
8010504b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105050:	5d                   	pop    %ebp
80105051:	c3                   	ret    

80105052 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105052:	55                   	push   %ebp
80105053:	89 e5                	mov    %esp,%ebp
80105055:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105058:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010505e:	8b 00                	mov    (%eax),%eax
80105060:	3b 45 08             	cmp    0x8(%ebp),%eax
80105063:	77 07                	ja     8010506c <fetchstr+0x1a>
    return -1;
80105065:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010506a:	eb 46                	jmp    801050b2 <fetchstr+0x60>
  *pp = (char*)addr;
8010506c:	8b 55 08             	mov    0x8(%ebp),%edx
8010506f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105072:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105074:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010507a:	8b 00                	mov    (%eax),%eax
8010507c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010507f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105082:	8b 00                	mov    (%eax),%eax
80105084:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105087:	eb 1c                	jmp    801050a5 <fetchstr+0x53>
    if(*s == 0)
80105089:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010508c:	8a 00                	mov    (%eax),%al
8010508e:	84 c0                	test   %al,%al
80105090:	75 10                	jne    801050a2 <fetchstr+0x50>
      return s - *pp;
80105092:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105095:	8b 45 0c             	mov    0xc(%ebp),%eax
80105098:	8b 00                	mov    (%eax),%eax
8010509a:	89 d1                	mov    %edx,%ecx
8010509c:	29 c1                	sub    %eax,%ecx
8010509e:	89 c8                	mov    %ecx,%eax
801050a0:	eb 10                	jmp    801050b2 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
801050a2:	ff 45 fc             	incl   -0x4(%ebp)
801050a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801050a8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801050ab:	72 dc                	jb     80105089 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
801050ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050b2:	c9                   	leave  
801050b3:	c3                   	ret    

801050b4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801050b4:	55                   	push   %ebp
801050b5:	89 e5                	mov    %esp,%ebp
801050b7:	83 ec 08             	sub    $0x8,%esp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801050ba:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050c0:	8b 40 18             	mov    0x18(%eax),%eax
801050c3:	8b 50 44             	mov    0x44(%eax),%edx
801050c6:	8b 45 08             	mov    0x8(%ebp),%eax
801050c9:	c1 e0 02             	shl    $0x2,%eax
801050cc:	01 d0                	add    %edx,%eax
801050ce:	8d 50 04             	lea    0x4(%eax),%edx
801050d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801050d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801050d8:	89 14 24             	mov    %edx,(%esp)
801050db:	e8 38 ff ff ff       	call   80105018 <fetchint>
}
801050e0:	c9                   	leave  
801050e1:	c3                   	ret    

801050e2 <argsig>:

// Fetch the 2nd sighandler_t system call argument.
int
argsig(int n, sighandler_t *handler)
{
801050e2:	55                   	push   %ebp
801050e3:	89 e5                	mov    %esp,%ebp
801050e5:	83 ec 10             	sub    $0x10,%esp
  int i;
  uint address = proc->tf->esp + 4 + (4 * n);
801050e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050ee:	8b 40 18             	mov    0x18(%eax),%eax
801050f1:	8b 50 44             	mov    0x44(%eax),%edx
801050f4:	8b 45 08             	mov    0x8(%ebp),%eax
801050f7:	c1 e0 02             	shl    $0x2,%eax
801050fa:	01 d0                	add    %edx,%eax
801050fc:	83 c0 04             	add    $0x4,%eax
801050ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  sighandler_t *temp = handler;
80105102:	8b 45 0c             	mov    0xc(%ebp),%eax
80105105:	89 45 f8             	mov    %eax,-0x8(%ebp)
  
  if(((address + 4) > proc->sz) || (address >= proc->sz))
80105108:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010510b:	8d 50 04             	lea    0x4(%eax),%edx
8010510e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105114:	8b 00                	mov    (%eax),%eax
80105116:	39 c2                	cmp    %eax,%edx
80105118:	77 0d                	ja     80105127 <argsig+0x45>
8010511a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105120:	8b 00                	mov    (%eax),%eax
80105122:	3b 45 fc             	cmp    -0x4(%ebp),%eax
80105125:	77 07                	ja     8010512e <argsig+0x4c>
    i = -1;
80105127:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  *temp = *(sighandler_t *)(address);
8010512e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105131:	8b 10                	mov    (%eax),%edx
80105133:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105136:	89 10                	mov    %edx,(%eax)
    i = 0;
80105138:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  
  return i;
8010513f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105142:	c9                   	leave  
80105143:	c3                   	ret    

80105144 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105144:	55                   	push   %ebp
80105145:	89 e5                	mov    %esp,%ebp
80105147:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010514a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010514d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105151:	8b 45 08             	mov    0x8(%ebp),%eax
80105154:	89 04 24             	mov    %eax,(%esp)
80105157:	e8 58 ff ff ff       	call   801050b4 <argint>
8010515c:	85 c0                	test   %eax,%eax
8010515e:	79 07                	jns    80105167 <argptr+0x23>
    return -1;
80105160:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105165:	eb 3d                	jmp    801051a4 <argptr+0x60>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105167:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010516a:	89 c2                	mov    %eax,%edx
8010516c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105172:	8b 00                	mov    (%eax),%eax
80105174:	39 c2                	cmp    %eax,%edx
80105176:	73 16                	jae    8010518e <argptr+0x4a>
80105178:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010517b:	89 c2                	mov    %eax,%edx
8010517d:	8b 45 10             	mov    0x10(%ebp),%eax
80105180:	01 c2                	add    %eax,%edx
80105182:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105188:	8b 00                	mov    (%eax),%eax
8010518a:	39 c2                	cmp    %eax,%edx
8010518c:	76 07                	jbe    80105195 <argptr+0x51>
    return -1;
8010518e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105193:	eb 0f                	jmp    801051a4 <argptr+0x60>
  *pp = (char*)i;
80105195:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105198:	89 c2                	mov    %eax,%edx
8010519a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010519d:	89 10                	mov    %edx,(%eax)
  return 0;
8010519f:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051a4:	c9                   	leave  
801051a5:	c3                   	ret    

801051a6 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801051a6:	55                   	push   %ebp
801051a7:	89 e5                	mov    %esp,%ebp
801051a9:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
801051ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
801051af:	89 44 24 04          	mov    %eax,0x4(%esp)
801051b3:	8b 45 08             	mov    0x8(%ebp),%eax
801051b6:	89 04 24             	mov    %eax,(%esp)
801051b9:	e8 f6 fe ff ff       	call   801050b4 <argint>
801051be:	85 c0                	test   %eax,%eax
801051c0:	79 07                	jns    801051c9 <argstr+0x23>
    return -1;
801051c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051c7:	eb 12                	jmp    801051db <argstr+0x35>
  return fetchstr(addr, pp);
801051c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801051cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801051cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801051d3:	89 04 24             	mov    %eax,(%esp)
801051d6:	e8 77 fe ff ff       	call   80105052 <fetchstr>
}
801051db:	c9                   	leave  
801051dc:	c3                   	ret    

801051dd <syscall>:
[SYS_signal]  sys_signal,   // USER DEFINED SYS CALL
};

void
syscall(void)
{
801051dd:	55                   	push   %ebp
801051de:	89 e5                	mov    %esp,%ebp
801051e0:	53                   	push   %ebx
801051e1:	83 ec 24             	sub    $0x24,%esp
  int num;

  num = proc->tf->eax;
801051e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ea:	8b 40 18             	mov    0x18(%eax),%eax
801051ed:	8b 40 1c             	mov    0x1c(%eax),%eax
801051f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801051f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051f7:	7e 30                	jle    80105229 <syscall+0x4c>
801051f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fc:	83 f8 18             	cmp    $0x18,%eax
801051ff:	77 28                	ja     80105229 <syscall+0x4c>
80105201:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105204:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010520b:	85 c0                	test   %eax,%eax
8010520d:	74 1a                	je     80105229 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
8010520f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105215:	8b 58 18             	mov    0x18(%eax),%ebx
80105218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010521b:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105222:	ff d0                	call   *%eax
80105224:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105227:	eb 3d                	jmp    80105266 <syscall+0x89>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105229:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010522f:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105232:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105238:	8b 40 10             	mov    0x10(%eax),%eax
8010523b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010523e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105242:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105246:	89 44 24 04          	mov    %eax,0x4(%esp)
8010524a:	c7 04 24 83 85 10 80 	movl   $0x80108583,(%esp)
80105251:	e8 4b b1 ff ff       	call   801003a1 <cprintf>
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105256:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010525c:	8b 40 18             	mov    0x18(%eax),%eax
8010525f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105266:	83 c4 24             	add    $0x24,%esp
80105269:	5b                   	pop    %ebx
8010526a:	5d                   	pop    %ebp
8010526b:	c3                   	ret    

8010526c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010526c:	55                   	push   %ebp
8010526d:	89 e5                	mov    %esp,%ebp
8010526f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105272:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105275:	89 44 24 04          	mov    %eax,0x4(%esp)
80105279:	8b 45 08             	mov    0x8(%ebp),%eax
8010527c:	89 04 24             	mov    %eax,(%esp)
8010527f:	e8 30 fe ff ff       	call   801050b4 <argint>
80105284:	85 c0                	test   %eax,%eax
80105286:	79 07                	jns    8010528f <argfd+0x23>
    return -1;
80105288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010528d:	eb 50                	jmp    801052df <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010528f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105292:	85 c0                	test   %eax,%eax
80105294:	78 21                	js     801052b7 <argfd+0x4b>
80105296:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105299:	83 f8 0f             	cmp    $0xf,%eax
8010529c:	7f 19                	jg     801052b7 <argfd+0x4b>
8010529e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052a7:	83 c2 08             	add    $0x8,%edx
801052aa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801052ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052b1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052b5:	75 07                	jne    801052be <argfd+0x52>
    return -1;
801052b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052bc:	eb 21                	jmp    801052df <argfd+0x73>
  if(pfd)
801052be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801052c2:	74 08                	je     801052cc <argfd+0x60>
    *pfd = fd;
801052c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ca:	89 10                	mov    %edx,(%eax)
  if(pf)
801052cc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801052d0:	74 08                	je     801052da <argfd+0x6e>
    *pf = f;
801052d2:	8b 45 10             	mov    0x10(%ebp),%eax
801052d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052d8:	89 10                	mov    %edx,(%eax)
  return 0;
801052da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052df:	c9                   	leave  
801052e0:	c3                   	ret    

801052e1 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801052e1:	55                   	push   %ebp
801052e2:	89 e5                	mov    %esp,%ebp
801052e4:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801052e7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801052ee:	eb 2f                	jmp    8010531f <fdalloc+0x3e>
    if(proc->ofile[fd] == 0){
801052f0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801052f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801052f9:	83 c2 08             	add    $0x8,%edx
801052fc:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105300:	85 c0                	test   %eax,%eax
80105302:	75 18                	jne    8010531c <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105304:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010530a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010530d:	8d 4a 08             	lea    0x8(%edx),%ecx
80105310:	8b 55 08             	mov    0x8(%ebp),%edx
80105313:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105317:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010531a:	eb 0e                	jmp    8010532a <fdalloc+0x49>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010531c:	ff 45 fc             	incl   -0x4(%ebp)
8010531f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105323:	7e cb                	jle    801052f0 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105325:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010532a:	c9                   	leave  
8010532b:	c3                   	ret    

8010532c <sys_dup>:

int
sys_dup(void)
{
8010532c:	55                   	push   %ebp
8010532d:	89 e5                	mov    %esp,%ebp
8010532f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105332:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105335:	89 44 24 08          	mov    %eax,0x8(%esp)
80105339:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105340:	00 
80105341:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105348:	e8 1f ff ff ff       	call   8010526c <argfd>
8010534d:	85 c0                	test   %eax,%eax
8010534f:	79 07                	jns    80105358 <sys_dup+0x2c>
    return -1;
80105351:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105356:	eb 29                	jmp    80105381 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535b:	89 04 24             	mov    %eax,(%esp)
8010535e:	e8 7e ff ff ff       	call   801052e1 <fdalloc>
80105363:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105366:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010536a:	79 07                	jns    80105373 <sys_dup+0x47>
    return -1;
8010536c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105371:	eb 0e                	jmp    80105381 <sys_dup+0x55>
  filedup(f);
80105373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105376:	89 04 24             	mov    %eax,(%esp)
80105379:	e8 d6 bb ff ff       	call   80100f54 <filedup>
  return fd;
8010537e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105381:	c9                   	leave  
80105382:	c3                   	ret    

80105383 <sys_read>:

int
sys_read(void)
{
80105383:	55                   	push   %ebp
80105384:	89 e5                	mov    %esp,%ebp
80105386:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105389:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010538c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105390:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105397:	00 
80105398:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010539f:	e8 c8 fe ff ff       	call   8010526c <argfd>
801053a4:	85 c0                	test   %eax,%eax
801053a6:	78 35                	js     801053dd <sys_read+0x5a>
801053a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801053ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801053af:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801053b6:	e8 f9 fc ff ff       	call   801050b4 <argint>
801053bb:	85 c0                	test   %eax,%eax
801053bd:	78 1e                	js     801053dd <sys_read+0x5a>
801053bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801053c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801053c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801053cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801053d4:	e8 6b fd ff ff       	call   80105144 <argptr>
801053d9:	85 c0                	test   %eax,%eax
801053db:	79 07                	jns    801053e4 <sys_read+0x61>
    return -1;
801053dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053e2:	eb 19                	jmp    801053fd <sys_read+0x7a>
  return fileread(f, p, n);
801053e4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801053e7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801053f1:	89 54 24 04          	mov    %edx,0x4(%esp)
801053f5:	89 04 24             	mov    %eax,(%esp)
801053f8:	e8 b8 bc ff ff       	call   801010b5 <fileread>
}
801053fd:	c9                   	leave  
801053fe:	c3                   	ret    

801053ff <sys_write>:

int
sys_write(void)
{
801053ff:	55                   	push   %ebp
80105400:	89 e5                	mov    %esp,%ebp
80105402:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105405:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105408:	89 44 24 08          	mov    %eax,0x8(%esp)
8010540c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105413:	00 
80105414:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010541b:	e8 4c fe ff ff       	call   8010526c <argfd>
80105420:	85 c0                	test   %eax,%eax
80105422:	78 35                	js     80105459 <sys_write+0x5a>
80105424:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105427:	89 44 24 04          	mov    %eax,0x4(%esp)
8010542b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105432:	e8 7d fc ff ff       	call   801050b4 <argint>
80105437:	85 c0                	test   %eax,%eax
80105439:	78 1e                	js     80105459 <sys_write+0x5a>
8010543b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010543e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105442:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105445:	89 44 24 04          	mov    %eax,0x4(%esp)
80105449:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105450:	e8 ef fc ff ff       	call   80105144 <argptr>
80105455:	85 c0                	test   %eax,%eax
80105457:	79 07                	jns    80105460 <sys_write+0x61>
    return -1;
80105459:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545e:	eb 19                	jmp    80105479 <sys_write+0x7a>
  return filewrite(f, p, n);
80105460:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105463:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105466:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105469:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010546d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105471:	89 04 24             	mov    %eax,(%esp)
80105474:	e8 f7 bc ff ff       	call   80101170 <filewrite>
}
80105479:	c9                   	leave  
8010547a:	c3                   	ret    

8010547b <sys_close>:

int
sys_close(void)
{
8010547b:	55                   	push   %ebp
8010547c:	89 e5                	mov    %esp,%ebp
8010547e:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105481:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105484:	89 44 24 08          	mov    %eax,0x8(%esp)
80105488:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010548b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010548f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105496:	e8 d1 fd ff ff       	call   8010526c <argfd>
8010549b:	85 c0                	test   %eax,%eax
8010549d:	79 07                	jns    801054a6 <sys_close+0x2b>
    return -1;
8010549f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054a4:	eb 24                	jmp    801054ca <sys_close+0x4f>
  proc->ofile[fd] = 0;
801054a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054af:	83 c2 08             	add    $0x8,%edx
801054b2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801054b9:	00 
  fileclose(f);
801054ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054bd:	89 04 24             	mov    %eax,(%esp)
801054c0:	e8 d7 ba ff ff       	call   80100f9c <fileclose>
  return 0;
801054c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054ca:	c9                   	leave  
801054cb:	c3                   	ret    

801054cc <sys_fstat>:

int
sys_fstat(void)
{
801054cc:	55                   	push   %ebp
801054cd:	89 e5                	mov    %esp,%ebp
801054cf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801054d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801054d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801054d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801054e0:	00 
801054e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801054e8:	e8 7f fd ff ff       	call   8010526c <argfd>
801054ed:	85 c0                	test   %eax,%eax
801054ef:	78 1f                	js     80105510 <sys_fstat+0x44>
801054f1:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801054f8:	00 
801054f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801054fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105500:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105507:	e8 38 fc ff ff       	call   80105144 <argptr>
8010550c:	85 c0                	test   %eax,%eax
8010550e:	79 07                	jns    80105517 <sys_fstat+0x4b>
    return -1;
80105510:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105515:	eb 12                	jmp    80105529 <sys_fstat+0x5d>
  return filestat(f, st);
80105517:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010551a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105521:	89 04 24             	mov    %eax,(%esp)
80105524:	e8 3d bb ff ff       	call   80101066 <filestat>
}
80105529:	c9                   	leave  
8010552a:	c3                   	ret    

8010552b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010552b:	55                   	push   %ebp
8010552c:	89 e5                	mov    %esp,%ebp
8010552e:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105531:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105534:	89 44 24 04          	mov    %eax,0x4(%esp)
80105538:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010553f:	e8 62 fc ff ff       	call   801051a6 <argstr>
80105544:	85 c0                	test   %eax,%eax
80105546:	78 17                	js     8010555f <sys_link+0x34>
80105548:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010554b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010554f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105556:	e8 4b fc ff ff       	call   801051a6 <argstr>
8010555b:	85 c0                	test   %eax,%eax
8010555d:	79 0a                	jns    80105569 <sys_link+0x3e>
    return -1;
8010555f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105564:	e9 37 01 00 00       	jmp    801056a0 <sys_link+0x175>
  if((ip = namei(old)) == 0)
80105569:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010556c:	89 04 24             	mov    %eax,(%esp)
8010556f:	e8 48 ce ff ff       	call   801023bc <namei>
80105574:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105577:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010557b:	75 0a                	jne    80105587 <sys_link+0x5c>
    return -1;
8010557d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105582:	e9 19 01 00 00       	jmp    801056a0 <sys_link+0x175>

  begin_trans();
80105587:	e8 23 dc ff ff       	call   801031af <begin_trans>

  ilock(ip);
8010558c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010558f:	89 04 24             	mov    %eax,(%esp)
80105592:	e8 8b c2 ff ff       	call   80101822 <ilock>
  if(ip->type == T_DIR){
80105597:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010559a:	8b 40 10             	mov    0x10(%eax),%eax
8010559d:	66 83 f8 01          	cmp    $0x1,%ax
801055a1:	75 1a                	jne    801055bd <sys_link+0x92>
    iunlockput(ip);
801055a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a6:	89 04 24             	mov    %eax,(%esp)
801055a9:	e8 f5 c4 ff ff       	call   80101aa3 <iunlockput>
    commit_trans();
801055ae:	e8 45 dc ff ff       	call   801031f8 <commit_trans>
    return -1;
801055b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b8:	e9 e3 00 00 00       	jmp    801056a0 <sys_link+0x175>
  }

  ip->nlink++;
801055bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055c0:	66 8b 40 16          	mov    0x16(%eax),%ax
801055c4:	40                   	inc    %eax
801055c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055c8:	66 89 42 16          	mov    %ax,0x16(%edx)
  iupdate(ip);
801055cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cf:	89 04 24             	mov    %eax,(%esp)
801055d2:	e8 91 c0 ff ff       	call   80101668 <iupdate>
  iunlock(ip);
801055d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055da:	89 04 24             	mov    %eax,(%esp)
801055dd:	e8 8b c3 ff ff       	call   8010196d <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801055e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055e5:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801055e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801055ec:	89 04 24             	mov    %eax,(%esp)
801055ef:	e8 ea cd ff ff       	call   801023de <nameiparent>
801055f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055fb:	74 68                	je     80105665 <sys_link+0x13a>
    goto bad;
  ilock(dp);
801055fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105600:	89 04 24             	mov    %eax,(%esp)
80105603:	e8 1a c2 ff ff       	call   80101822 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105608:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010560b:	8b 10                	mov    (%eax),%edx
8010560d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105610:	8b 00                	mov    (%eax),%eax
80105612:	39 c2                	cmp    %eax,%edx
80105614:	75 20                	jne    80105636 <sys_link+0x10b>
80105616:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105619:	8b 40 04             	mov    0x4(%eax),%eax
8010561c:	89 44 24 08          	mov    %eax,0x8(%esp)
80105620:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105623:	89 44 24 04          	mov    %eax,0x4(%esp)
80105627:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010562a:	89 04 24             	mov    %eax,(%esp)
8010562d:	e8 d3 ca ff ff       	call   80102105 <dirlink>
80105632:	85 c0                	test   %eax,%eax
80105634:	79 0d                	jns    80105643 <sys_link+0x118>
    iunlockput(dp);
80105636:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105639:	89 04 24             	mov    %eax,(%esp)
8010563c:	e8 62 c4 ff ff       	call   80101aa3 <iunlockput>
    goto bad;
80105641:	eb 23                	jmp    80105666 <sys_link+0x13b>
  }
  iunlockput(dp);
80105643:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105646:	89 04 24             	mov    %eax,(%esp)
80105649:	e8 55 c4 ff ff       	call   80101aa3 <iunlockput>
  iput(ip);
8010564e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105651:	89 04 24             	mov    %eax,(%esp)
80105654:	e8 79 c3 ff ff       	call   801019d2 <iput>

  commit_trans();
80105659:	e8 9a db ff ff       	call   801031f8 <commit_trans>

  return 0;
8010565e:	b8 00 00 00 00       	mov    $0x0,%eax
80105663:	eb 3b                	jmp    801056a0 <sys_link+0x175>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105665:	90                   	nop
  commit_trans();

  return 0;

bad:
  ilock(ip);
80105666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105669:	89 04 24             	mov    %eax,(%esp)
8010566c:	e8 b1 c1 ff ff       	call   80101822 <ilock>
  ip->nlink--;
80105671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105674:	66 8b 40 16          	mov    0x16(%eax),%ax
80105678:	48                   	dec    %eax
80105679:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010567c:	66 89 42 16          	mov    %ax,0x16(%edx)
  iupdate(ip);
80105680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105683:	89 04 24             	mov    %eax,(%esp)
80105686:	e8 dd bf ff ff       	call   80101668 <iupdate>
  iunlockput(ip);
8010568b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010568e:	89 04 24             	mov    %eax,(%esp)
80105691:	e8 0d c4 ff ff       	call   80101aa3 <iunlockput>
  commit_trans();
80105696:	e8 5d db ff ff       	call   801031f8 <commit_trans>
  return -1;
8010569b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056a0:	c9                   	leave  
801056a1:	c3                   	ret    

801056a2 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801056a2:	55                   	push   %ebp
801056a3:	89 e5                	mov    %esp,%ebp
801056a5:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056a8:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801056af:	eb 4a                	jmp    801056fb <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b4:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801056bb:	00 
801056bc:	89 44 24 08          	mov    %eax,0x8(%esp)
801056c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801056c3:	89 44 24 04          	mov    %eax,0x4(%esp)
801056c7:	8b 45 08             	mov    0x8(%ebp),%eax
801056ca:	89 04 24             	mov    %eax,(%esp)
801056cd:	e8 57 c6 ff ff       	call   80101d29 <readi>
801056d2:	83 f8 10             	cmp    $0x10,%eax
801056d5:	74 0c                	je     801056e3 <isdirempty+0x41>
      panic("isdirempty: readi");
801056d7:	c7 04 24 9f 85 10 80 	movl   $0x8010859f,(%esp)
801056de:	e8 53 ae ff ff       	call   80100536 <panic>
    if(de.inum != 0)
801056e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801056e6:	66 85 c0             	test   %ax,%ax
801056e9:	74 07                	je     801056f2 <isdirempty+0x50>
      return 0;
801056eb:	b8 00 00 00 00       	mov    $0x0,%eax
801056f0:	eb 1b                	jmp    8010570d <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801056f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f5:	83 c0 10             	add    $0x10,%eax
801056f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105701:	8b 40 18             	mov    0x18(%eax),%eax
80105704:	39 c2                	cmp    %eax,%edx
80105706:	72 a9                	jb     801056b1 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105708:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010570d:	c9                   	leave  
8010570e:	c3                   	ret    

8010570f <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010570f:	55                   	push   %ebp
80105710:	89 e5                	mov    %esp,%ebp
80105712:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105715:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105718:	89 44 24 04          	mov    %eax,0x4(%esp)
8010571c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105723:	e8 7e fa ff ff       	call   801051a6 <argstr>
80105728:	85 c0                	test   %eax,%eax
8010572a:	79 0a                	jns    80105736 <sys_unlink+0x27>
    return -1;
8010572c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105731:	e9 a4 01 00 00       	jmp    801058da <sys_unlink+0x1cb>
  if((dp = nameiparent(path, name)) == 0)
80105736:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105739:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010573c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105740:	89 04 24             	mov    %eax,(%esp)
80105743:	e8 96 cc ff ff       	call   801023de <nameiparent>
80105748:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010574b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010574f:	75 0a                	jne    8010575b <sys_unlink+0x4c>
    return -1;
80105751:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105756:	e9 7f 01 00 00       	jmp    801058da <sys_unlink+0x1cb>

  begin_trans();
8010575b:	e8 4f da ff ff       	call   801031af <begin_trans>

  ilock(dp);
80105760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105763:	89 04 24             	mov    %eax,(%esp)
80105766:	e8 b7 c0 ff ff       	call   80101822 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010576b:	c7 44 24 04 b1 85 10 	movl   $0x801085b1,0x4(%esp)
80105772:	80 
80105773:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105776:	89 04 24             	mov    %eax,(%esp)
80105779:	e8 a0 c8 ff ff       	call   8010201e <namecmp>
8010577e:	85 c0                	test   %eax,%eax
80105780:	0f 84 3f 01 00 00    	je     801058c5 <sys_unlink+0x1b6>
80105786:	c7 44 24 04 b3 85 10 	movl   $0x801085b3,0x4(%esp)
8010578d:	80 
8010578e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105791:	89 04 24             	mov    %eax,(%esp)
80105794:	e8 85 c8 ff ff       	call   8010201e <namecmp>
80105799:	85 c0                	test   %eax,%eax
8010579b:	0f 84 24 01 00 00    	je     801058c5 <sys_unlink+0x1b6>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801057a1:	8d 45 c8             	lea    -0x38(%ebp),%eax
801057a4:	89 44 24 08          	mov    %eax,0x8(%esp)
801057a8:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801057ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801057af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057b2:	89 04 24             	mov    %eax,(%esp)
801057b5:	e8 86 c8 ff ff       	call   80102040 <dirlookup>
801057ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057c1:	0f 84 fd 00 00 00    	je     801058c4 <sys_unlink+0x1b5>
    goto bad;
  ilock(ip);
801057c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ca:	89 04 24             	mov    %eax,(%esp)
801057cd:	e8 50 c0 ff ff       	call   80101822 <ilock>

  if(ip->nlink < 1)
801057d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057d5:	66 8b 40 16          	mov    0x16(%eax),%ax
801057d9:	66 85 c0             	test   %ax,%ax
801057dc:	7f 0c                	jg     801057ea <sys_unlink+0xdb>
    panic("unlink: nlink < 1");
801057de:	c7 04 24 b6 85 10 80 	movl   $0x801085b6,(%esp)
801057e5:	e8 4c ad ff ff       	call   80100536 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801057ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057ed:	8b 40 10             	mov    0x10(%eax),%eax
801057f0:	66 83 f8 01          	cmp    $0x1,%ax
801057f4:	75 1f                	jne    80105815 <sys_unlink+0x106>
801057f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f9:	89 04 24             	mov    %eax,(%esp)
801057fc:	e8 a1 fe ff ff       	call   801056a2 <isdirempty>
80105801:	85 c0                	test   %eax,%eax
80105803:	75 10                	jne    80105815 <sys_unlink+0x106>
    iunlockput(ip);
80105805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105808:	89 04 24             	mov    %eax,(%esp)
8010580b:	e8 93 c2 ff ff       	call   80101aa3 <iunlockput>
    goto bad;
80105810:	e9 b0 00 00 00       	jmp    801058c5 <sys_unlink+0x1b6>
  }

  memset(&de, 0, sizeof(de));
80105815:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010581c:	00 
8010581d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105824:	00 
80105825:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105828:	89 04 24             	mov    %eax,(%esp)
8010582b:	e8 4e f5 ff ff       	call   80104d7e <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105830:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105833:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010583a:	00 
8010583b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010583f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105842:	89 44 24 04          	mov    %eax,0x4(%esp)
80105846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105849:	89 04 24             	mov    %eax,(%esp)
8010584c:	e8 3d c6 ff ff       	call   80101e8e <writei>
80105851:	83 f8 10             	cmp    $0x10,%eax
80105854:	74 0c                	je     80105862 <sys_unlink+0x153>
    panic("unlink: writei");
80105856:	c7 04 24 c8 85 10 80 	movl   $0x801085c8,(%esp)
8010585d:	e8 d4 ac ff ff       	call   80100536 <panic>
  if(ip->type == T_DIR){
80105862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105865:	8b 40 10             	mov    0x10(%eax),%eax
80105868:	66 83 f8 01          	cmp    $0x1,%ax
8010586c:	75 1a                	jne    80105888 <sys_unlink+0x179>
    dp->nlink--;
8010586e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105871:	66 8b 40 16          	mov    0x16(%eax),%ax
80105875:	48                   	dec    %eax
80105876:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105879:	66 89 42 16          	mov    %ax,0x16(%edx)
    iupdate(dp);
8010587d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105880:	89 04 24             	mov    %eax,(%esp)
80105883:	e8 e0 bd ff ff       	call   80101668 <iupdate>
  }
  iunlockput(dp);
80105888:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010588b:	89 04 24             	mov    %eax,(%esp)
8010588e:	e8 10 c2 ff ff       	call   80101aa3 <iunlockput>

  ip->nlink--;
80105893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105896:	66 8b 40 16          	mov    0x16(%eax),%ax
8010589a:	48                   	dec    %eax
8010589b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010589e:	66 89 42 16          	mov    %ax,0x16(%edx)
  iupdate(ip);
801058a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a5:	89 04 24             	mov    %eax,(%esp)
801058a8:	e8 bb bd ff ff       	call   80101668 <iupdate>
  iunlockput(ip);
801058ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058b0:	89 04 24             	mov    %eax,(%esp)
801058b3:	e8 eb c1 ff ff       	call   80101aa3 <iunlockput>

  commit_trans();
801058b8:	e8 3b d9 ff ff       	call   801031f8 <commit_trans>

  return 0;
801058bd:	b8 00 00 00 00       	mov    $0x0,%eax
801058c2:	eb 16                	jmp    801058da <sys_unlink+0x1cb>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801058c4:	90                   	nop
  commit_trans();

  return 0;

bad:
  iunlockput(dp);
801058c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058c8:	89 04 24             	mov    %eax,(%esp)
801058cb:	e8 d3 c1 ff ff       	call   80101aa3 <iunlockput>
  commit_trans();
801058d0:	e8 23 d9 ff ff       	call   801031f8 <commit_trans>
  return -1;
801058d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801058da:	c9                   	leave  
801058db:	c3                   	ret    

801058dc <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801058dc:	55                   	push   %ebp
801058dd:	89 e5                	mov    %esp,%ebp
801058df:	83 ec 48             	sub    $0x48,%esp
801058e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801058e5:	8b 55 10             	mov    0x10(%ebp),%edx
801058e8:	8b 45 14             	mov    0x14(%ebp),%eax
801058eb:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801058ef:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801058f3:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801058f7:	8d 45 de             	lea    -0x22(%ebp),%eax
801058fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801058fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105901:	89 04 24             	mov    %eax,(%esp)
80105904:	e8 d5 ca ff ff       	call   801023de <nameiparent>
80105909:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010590c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105910:	75 0a                	jne    8010591c <create+0x40>
    return 0;
80105912:	b8 00 00 00 00       	mov    $0x0,%eax
80105917:	e9 79 01 00 00       	jmp    80105a95 <create+0x1b9>
  ilock(dp);
8010591c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010591f:	89 04 24             	mov    %eax,(%esp)
80105922:	e8 fb be ff ff       	call   80101822 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105927:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010592a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010592e:	8d 45 de             	lea    -0x22(%ebp),%eax
80105931:	89 44 24 04          	mov    %eax,0x4(%esp)
80105935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105938:	89 04 24             	mov    %eax,(%esp)
8010593b:	e8 00 c7 ff ff       	call   80102040 <dirlookup>
80105940:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105943:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105947:	74 46                	je     8010598f <create+0xb3>
    iunlockput(dp);
80105949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010594c:	89 04 24             	mov    %eax,(%esp)
8010594f:	e8 4f c1 ff ff       	call   80101aa3 <iunlockput>
    ilock(ip);
80105954:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105957:	89 04 24             	mov    %eax,(%esp)
8010595a:	e8 c3 be ff ff       	call   80101822 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010595f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105964:	75 14                	jne    8010597a <create+0x9e>
80105966:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105969:	8b 40 10             	mov    0x10(%eax),%eax
8010596c:	66 83 f8 02          	cmp    $0x2,%ax
80105970:	75 08                	jne    8010597a <create+0x9e>
      return ip;
80105972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105975:	e9 1b 01 00 00       	jmp    80105a95 <create+0x1b9>
    iunlockput(ip);
8010597a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010597d:	89 04 24             	mov    %eax,(%esp)
80105980:	e8 1e c1 ff ff       	call   80101aa3 <iunlockput>
    return 0;
80105985:	b8 00 00 00 00       	mov    $0x0,%eax
8010598a:	e9 06 01 00 00       	jmp    80105a95 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010598f:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105993:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105996:	8b 00                	mov    (%eax),%eax
80105998:	89 54 24 04          	mov    %edx,0x4(%esp)
8010599c:	89 04 24             	mov    %eax,(%esp)
8010599f:	e8 e8 bb ff ff       	call   8010158c <ialloc>
801059a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059ab:	75 0c                	jne    801059b9 <create+0xdd>
    panic("create: ialloc");
801059ad:	c7 04 24 d7 85 10 80 	movl   $0x801085d7,(%esp)
801059b4:	e8 7d ab ff ff       	call   80100536 <panic>

  ilock(ip);
801059b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bc:	89 04 24             	mov    %eax,(%esp)
801059bf:	e8 5e be ff ff       	call   80101822 <ilock>
  ip->major = major;
801059c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801059ca:	66 89 42 12          	mov    %ax,0x12(%edx)
  ip->minor = minor;
801059ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059d1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801059d4:	66 89 42 14          	mov    %ax,0x14(%edx)
  ip->nlink = 1;
801059d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059db:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801059e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e4:	89 04 24             	mov    %eax,(%esp)
801059e7:	e8 7c bc ff ff       	call   80101668 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801059ec:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801059f1:	75 68                	jne    80105a5b <create+0x17f>
    dp->nlink++;  // for ".."
801059f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059f6:	66 8b 40 16          	mov    0x16(%eax),%ax
801059fa:	40                   	inc    %eax
801059fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059fe:	66 89 42 16          	mov    %ax,0x16(%edx)
    iupdate(dp);
80105a02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a05:	89 04 24             	mov    %eax,(%esp)
80105a08:	e8 5b bc ff ff       	call   80101668 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a10:	8b 40 04             	mov    0x4(%eax),%eax
80105a13:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a17:	c7 44 24 04 b1 85 10 	movl   $0x801085b1,0x4(%esp)
80105a1e:	80 
80105a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a22:	89 04 24             	mov    %eax,(%esp)
80105a25:	e8 db c6 ff ff       	call   80102105 <dirlink>
80105a2a:	85 c0                	test   %eax,%eax
80105a2c:	78 21                	js     80105a4f <create+0x173>
80105a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a31:	8b 40 04             	mov    0x4(%eax),%eax
80105a34:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a38:	c7 44 24 04 b3 85 10 	movl   $0x801085b3,0x4(%esp)
80105a3f:	80 
80105a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a43:	89 04 24             	mov    %eax,(%esp)
80105a46:	e8 ba c6 ff ff       	call   80102105 <dirlink>
80105a4b:	85 c0                	test   %eax,%eax
80105a4d:	79 0c                	jns    80105a5b <create+0x17f>
      panic("create dots");
80105a4f:	c7 04 24 e6 85 10 80 	movl   $0x801085e6,(%esp)
80105a56:	e8 db aa ff ff       	call   80100536 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a5e:	8b 40 04             	mov    0x4(%eax),%eax
80105a61:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a65:	8d 45 de             	lea    -0x22(%ebp),%eax
80105a68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6f:	89 04 24             	mov    %eax,(%esp)
80105a72:	e8 8e c6 ff ff       	call   80102105 <dirlink>
80105a77:	85 c0                	test   %eax,%eax
80105a79:	79 0c                	jns    80105a87 <create+0x1ab>
    panic("create: dirlink");
80105a7b:	c7 04 24 f2 85 10 80 	movl   $0x801085f2,(%esp)
80105a82:	e8 af aa ff ff       	call   80100536 <panic>

  iunlockput(dp);
80105a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a8a:	89 04 24             	mov    %eax,(%esp)
80105a8d:	e8 11 c0 ff ff       	call   80101aa3 <iunlockput>

  return ip;
80105a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105a95:	c9                   	leave  
80105a96:	c3                   	ret    

80105a97 <sys_open>:

int
sys_open(void)
{
80105a97:	55                   	push   %ebp
80105a98:	89 e5                	mov    %esp,%ebp
80105a9a:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105a9d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105aa0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aa4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105aab:	e8 f6 f6 ff ff       	call   801051a6 <argstr>
80105ab0:	85 c0                	test   %eax,%eax
80105ab2:	78 17                	js     80105acb <sys_open+0x34>
80105ab4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105abb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ac2:	e8 ed f5 ff ff       	call   801050b4 <argint>
80105ac7:	85 c0                	test   %eax,%eax
80105ac9:	79 0a                	jns    80105ad5 <sys_open+0x3e>
    return -1;
80105acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ad0:	e9 47 01 00 00       	jmp    80105c1c <sys_open+0x185>
  if(omode & O_CREATE){
80105ad5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ad8:	25 00 02 00 00       	and    $0x200,%eax
80105add:	85 c0                	test   %eax,%eax
80105adf:	74 40                	je     80105b21 <sys_open+0x8a>
    begin_trans();
80105ae1:	e8 c9 d6 ff ff       	call   801031af <begin_trans>
    ip = create(path, T_FILE, 0, 0);
80105ae6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ae9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105af0:	00 
80105af1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105af8:	00 
80105af9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80105b00:	00 
80105b01:	89 04 24             	mov    %eax,(%esp)
80105b04:	e8 d3 fd ff ff       	call   801058dc <create>
80105b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    commit_trans();
80105b0c:	e8 e7 d6 ff ff       	call   801031f8 <commit_trans>
    if(ip == 0)
80105b11:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b15:	75 5b                	jne    80105b72 <sys_open+0xdb>
      return -1;
80105b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b1c:	e9 fb 00 00 00       	jmp    80105c1c <sys_open+0x185>
  } else {
    if((ip = namei(path)) == 0)
80105b21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b24:	89 04 24             	mov    %eax,(%esp)
80105b27:	e8 90 c8 ff ff       	call   801023bc <namei>
80105b2c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b2f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b33:	75 0a                	jne    80105b3f <sys_open+0xa8>
      return -1;
80105b35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b3a:	e9 dd 00 00 00       	jmp    80105c1c <sys_open+0x185>
    ilock(ip);
80105b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b42:	89 04 24             	mov    %eax,(%esp)
80105b45:	e8 d8 bc ff ff       	call   80101822 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b4d:	8b 40 10             	mov    0x10(%eax),%eax
80105b50:	66 83 f8 01          	cmp    $0x1,%ax
80105b54:	75 1c                	jne    80105b72 <sys_open+0xdb>
80105b56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b59:	85 c0                	test   %eax,%eax
80105b5b:	74 15                	je     80105b72 <sys_open+0xdb>
      iunlockput(ip);
80105b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b60:	89 04 24             	mov    %eax,(%esp)
80105b63:	e8 3b bf ff ff       	call   80101aa3 <iunlockput>
      return -1;
80105b68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6d:	e9 aa 00 00 00       	jmp    80105c1c <sys_open+0x185>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105b72:	e8 7d b3 ff ff       	call   80100ef4 <filealloc>
80105b77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b7a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b7e:	74 14                	je     80105b94 <sys_open+0xfd>
80105b80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b83:	89 04 24             	mov    %eax,(%esp)
80105b86:	e8 56 f7 ff ff       	call   801052e1 <fdalloc>
80105b8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105b8e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105b92:	79 23                	jns    80105bb7 <sys_open+0x120>
    if(f)
80105b94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b98:	74 0b                	je     80105ba5 <sys_open+0x10e>
      fileclose(f);
80105b9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9d:	89 04 24             	mov    %eax,(%esp)
80105ba0:	e8 f7 b3 ff ff       	call   80100f9c <fileclose>
    iunlockput(ip);
80105ba5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba8:	89 04 24             	mov    %eax,(%esp)
80105bab:	e8 f3 be ff ff       	call   80101aa3 <iunlockput>
    return -1;
80105bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bb5:	eb 65                	jmp    80105c1c <sys_open+0x185>
  }
  iunlock(ip);
80105bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bba:	89 04 24             	mov    %eax,(%esp)
80105bbd:	e8 ab bd ff ff       	call   8010196d <iunlock>

  f->type = FD_INODE;
80105bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bc5:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bce:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bd1:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80105bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105bde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105be1:	83 e0 01             	and    $0x1,%eax
80105be4:	85 c0                	test   %eax,%eax
80105be6:	0f 94 c0             	sete   %al
80105be9:	88 c2                	mov    %al,%dl
80105beb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bee:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105bf1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bf4:	83 e0 01             	and    $0x1,%eax
80105bf7:	85 c0                	test   %eax,%eax
80105bf9:	75 0a                	jne    80105c05 <sys_open+0x16e>
80105bfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bfe:	83 e0 02             	and    $0x2,%eax
80105c01:	85 c0                	test   %eax,%eax
80105c03:	74 07                	je     80105c0c <sys_open+0x175>
80105c05:	b8 01 00 00 00       	mov    $0x1,%eax
80105c0a:	eb 05                	jmp    80105c11 <sys_open+0x17a>
80105c0c:	b8 00 00 00 00       	mov    $0x0,%eax
80105c11:	88 c2                	mov    %al,%dl
80105c13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c16:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80105c19:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80105c1c:	c9                   	leave  
80105c1d:	c3                   	ret    

80105c1e <sys_mkdir>:

int
sys_mkdir(void)
{
80105c1e:	55                   	push   %ebp
80105c1f:	89 e5                	mov    %esp,%ebp
80105c21:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_trans();
80105c24:	e8 86 d5 ff ff       	call   801031af <begin_trans>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80105c29:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c37:	e8 6a f5 ff ff       	call   801051a6 <argstr>
80105c3c:	85 c0                	test   %eax,%eax
80105c3e:	78 2c                	js     80105c6c <sys_mkdir+0x4e>
80105c40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105c4a:	00 
80105c4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105c52:	00 
80105c53:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105c5a:	00 
80105c5b:	89 04 24             	mov    %eax,(%esp)
80105c5e:	e8 79 fc ff ff       	call   801058dc <create>
80105c63:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c66:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c6a:	75 0c                	jne    80105c78 <sys_mkdir+0x5a>
    commit_trans();
80105c6c:	e8 87 d5 ff ff       	call   801031f8 <commit_trans>
    return -1;
80105c71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c76:	eb 15                	jmp    80105c8d <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80105c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c7b:	89 04 24             	mov    %eax,(%esp)
80105c7e:	e8 20 be ff ff       	call   80101aa3 <iunlockput>
  commit_trans();
80105c83:	e8 70 d5 ff ff       	call   801031f8 <commit_trans>
  return 0;
80105c88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c8d:	c9                   	leave  
80105c8e:	c3                   	ret    

80105c8f <sys_mknod>:

int
sys_mknod(void)
{
80105c8f:	55                   	push   %ebp
80105c90:	89 e5                	mov    %esp,%ebp
80105c92:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
80105c95:	e8 15 d5 ff ff       	call   801031af <begin_trans>
  if((len=argstr(0, &path)) < 0 ||
80105c9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ca1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ca8:	e8 f9 f4 ff ff       	call   801051a6 <argstr>
80105cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cb4:	78 5e                	js     80105d14 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
80105cb6:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cc4:	e8 eb f3 ff ff       	call   801050b4 <argint>
  char *path;
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
80105cc9:	85 c0                	test   %eax,%eax
80105ccb:	78 47                	js     80105d14 <sys_mknod+0x85>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105ccd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cd4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105cdb:	e8 d4 f3 ff ff       	call   801050b4 <argint>
  int len;
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80105ce0:	85 c0                	test   %eax,%eax
80105ce2:	78 30                	js     80105d14 <sys_mknod+0x85>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80105ce4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ce7:	0f bf c8             	movswl %ax,%ecx
80105cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105ced:	0f bf d0             	movswl %ax,%edx
80105cf0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_trans();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80105cf3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105cf7:	89 54 24 08          	mov    %edx,0x8(%esp)
80105cfb:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80105d02:	00 
80105d03:	89 04 24             	mov    %eax,(%esp)
80105d06:	e8 d1 fb ff ff       	call   801058dc <create>
80105d0b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105d0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105d12:	75 0c                	jne    80105d20 <sys_mknod+0x91>
     (ip = create(path, T_DEV, major, minor)) == 0){
    commit_trans();
80105d14:	e8 df d4 ff ff       	call   801031f8 <commit_trans>
    return -1;
80105d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1e:	eb 15                	jmp    80105d35 <sys_mknod+0xa6>
  }
  iunlockput(ip);
80105d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d23:	89 04 24             	mov    %eax,(%esp)
80105d26:	e8 78 bd ff ff       	call   80101aa3 <iunlockput>
  commit_trans();
80105d2b:	e8 c8 d4 ff ff       	call   801031f8 <commit_trans>
  return 0;
80105d30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d35:	c9                   	leave  
80105d36:	c3                   	ret    

80105d37 <sys_chdir>:

int
sys_chdir(void)
{
80105d37:	55                   	push   %ebp
80105d38:	89 e5                	mov    %esp,%ebp
80105d3a:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0)
80105d3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d40:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d4b:	e8 56 f4 ff ff       	call   801051a6 <argstr>
80105d50:	85 c0                	test   %eax,%eax
80105d52:	78 14                	js     80105d68 <sys_chdir+0x31>
80105d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d57:	89 04 24             	mov    %eax,(%esp)
80105d5a:	e8 5d c6 ff ff       	call   801023bc <namei>
80105d5f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d62:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d66:	75 07                	jne    80105d6f <sys_chdir+0x38>
    return -1;
80105d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6d:	eb 56                	jmp    80105dc5 <sys_chdir+0x8e>
  ilock(ip);
80105d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d72:	89 04 24             	mov    %eax,(%esp)
80105d75:	e8 a8 ba ff ff       	call   80101822 <ilock>
  if(ip->type != T_DIR){
80105d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d7d:	8b 40 10             	mov    0x10(%eax),%eax
80105d80:	66 83 f8 01          	cmp    $0x1,%ax
80105d84:	74 12                	je     80105d98 <sys_chdir+0x61>
    iunlockput(ip);
80105d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d89:	89 04 24             	mov    %eax,(%esp)
80105d8c:	e8 12 bd ff ff       	call   80101aa3 <iunlockput>
    return -1;
80105d91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d96:	eb 2d                	jmp    80105dc5 <sys_chdir+0x8e>
  }
  iunlock(ip);
80105d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9b:	89 04 24             	mov    %eax,(%esp)
80105d9e:	e8 ca bb ff ff       	call   8010196d <iunlock>
  iput(proc->cwd);
80105da3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105da9:	8b 40 68             	mov    0x68(%eax),%eax
80105dac:	89 04 24             	mov    %eax,(%esp)
80105daf:	e8 1e bc ff ff       	call   801019d2 <iput>
  proc->cwd = ip;
80105db4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105dba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dbd:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105dc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dc5:	c9                   	leave  
80105dc6:	c3                   	ret    

80105dc7 <sys_exec>:

int
sys_exec(void)
{
80105dc7:	55                   	push   %ebp
80105dc8:	89 e5                	mov    %esp,%ebp
80105dca:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105dd0:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dd3:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dde:	e8 c3 f3 ff ff       	call   801051a6 <argstr>
80105de3:	85 c0                	test   %eax,%eax
80105de5:	78 1a                	js     80105e01 <sys_exec+0x3a>
80105de7:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80105df1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105df8:	e8 b7 f2 ff ff       	call   801050b4 <argint>
80105dfd:	85 c0                	test   %eax,%eax
80105dff:	79 0a                	jns    80105e0b <sys_exec+0x44>
    return -1;
80105e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e06:	e9 c7 00 00 00       	jmp    80105ed2 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80105e0b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80105e12:	00 
80105e13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e1a:	00 
80105e1b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105e21:	89 04 24             	mov    %eax,(%esp)
80105e24:	e8 55 ef ff ff       	call   80104d7e <memset>
  for(i=0;; i++){
80105e29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e33:	83 f8 1f             	cmp    $0x1f,%eax
80105e36:	76 0a                	jbe    80105e42 <sys_exec+0x7b>
      return -1;
80105e38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e3d:	e9 90 00 00 00       	jmp    80105ed2 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e45:	c1 e0 02             	shl    $0x2,%eax
80105e48:	89 c2                	mov    %eax,%edx
80105e4a:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105e50:	01 c2                	add    %eax,%edx
80105e52:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105e58:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e5c:	89 14 24             	mov    %edx,(%esp)
80105e5f:	e8 b4 f1 ff ff       	call   80105018 <fetchint>
80105e64:	85 c0                	test   %eax,%eax
80105e66:	79 07                	jns    80105e6f <sys_exec+0xa8>
      return -1;
80105e68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e6d:	eb 63                	jmp    80105ed2 <sys_exec+0x10b>
    if(uarg == 0){
80105e6f:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105e75:	85 c0                	test   %eax,%eax
80105e77:	75 26                	jne    80105e9f <sys_exec+0xd8>
      argv[i] = 0;
80105e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7c:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105e83:	00 00 00 00 
      break;
80105e87:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8b:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105e91:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e95:	89 04 24             	mov    %eax,(%esp)
80105e98:	e8 2f ac ff ff       	call   80100acc <exec>
80105e9d:	eb 33                	jmp    80105ed2 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105e9f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ea5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ea8:	c1 e2 02             	shl    $0x2,%edx
80105eab:	01 c2                	add    %eax,%edx
80105ead:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105eb3:	89 54 24 04          	mov    %edx,0x4(%esp)
80105eb7:	89 04 24             	mov    %eax,(%esp)
80105eba:	e8 93 f1 ff ff       	call   80105052 <fetchstr>
80105ebf:	85 c0                	test   %eax,%eax
80105ec1:	79 07                	jns    80105eca <sys_exec+0x103>
      return -1;
80105ec3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ec8:	eb 08                	jmp    80105ed2 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80105eca:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80105ecd:	e9 5e ff ff ff       	jmp    80105e30 <sys_exec+0x69>
  return exec(path, argv);
}
80105ed2:	c9                   	leave  
80105ed3:	c3                   	ret    

80105ed4 <sys_pipe>:

int
sys_pipe(void)
{
80105ed4:	55                   	push   %ebp
80105ed5:	89 e5                	mov    %esp,%ebp
80105ed7:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105eda:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80105ee1:	00 
80105ee2:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ee5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ee9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ef0:	e8 4f f2 ff ff       	call   80105144 <argptr>
80105ef5:	85 c0                	test   %eax,%eax
80105ef7:	79 0a                	jns    80105f03 <sys_pipe+0x2f>
    return -1;
80105ef9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105efe:	e9 9b 00 00 00       	jmp    80105f9e <sys_pipe+0xca>
  if(pipealloc(&rf, &wf) < 0)
80105f03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f06:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0a:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f0d:	89 04 24             	mov    %eax,(%esp)
80105f10:	e8 e3 dc ff ff       	call   80103bf8 <pipealloc>
80105f15:	85 c0                	test   %eax,%eax
80105f17:	79 07                	jns    80105f20 <sys_pipe+0x4c>
    return -1;
80105f19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1e:	eb 7e                	jmp    80105f9e <sys_pipe+0xca>
  fd0 = -1;
80105f20:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105f27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f2a:	89 04 24             	mov    %eax,(%esp)
80105f2d:	e8 af f3 ff ff       	call   801052e1 <fdalloc>
80105f32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f39:	78 14                	js     80105f4f <sys_pipe+0x7b>
80105f3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f3e:	89 04 24             	mov    %eax,(%esp)
80105f41:	e8 9b f3 ff ff       	call   801052e1 <fdalloc>
80105f46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f4d:	79 37                	jns    80105f86 <sys_pipe+0xb2>
    if(fd0 >= 0)
80105f4f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f53:	78 14                	js     80105f69 <sys_pipe+0x95>
      proc->ofile[fd0] = 0;
80105f55:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105f5b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f5e:	83 c2 08             	add    $0x8,%edx
80105f61:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105f68:	00 
    fileclose(rf);
80105f69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105f6c:	89 04 24             	mov    %eax,(%esp)
80105f6f:	e8 28 b0 ff ff       	call   80100f9c <fileclose>
    fileclose(wf);
80105f74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f77:	89 04 24             	mov    %eax,(%esp)
80105f7a:	e8 1d b0 ff ff       	call   80100f9c <fileclose>
    return -1;
80105f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f84:	eb 18                	jmp    80105f9e <sys_pipe+0xca>
  }
  fd[0] = fd0;
80105f86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f8c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105f8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105f91:	8d 50 04             	lea    0x4(%eax),%edx
80105f94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f97:	89 02                	mov    %eax,(%edx)
  return 0;
80105f99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f9e:	c9                   	leave  
80105f9f:	c3                   	ret    

80105fa0 <sys_fork>:
#include "proc.h"
#include "traps.h"

int
sys_fork(void)
{
80105fa0:	55                   	push   %ebp
80105fa1:	89 e5                	mov    %esp,%ebp
80105fa3:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105fa6:	e8 1e e3 ff ff       	call   801042c9 <fork>
}
80105fab:	c9                   	leave  
80105fac:	c3                   	ret    

80105fad <sys_exit>:

int
sys_exit(void)
{
80105fad:	55                   	push   %ebp
80105fae:	89 e5                	mov    %esp,%ebp
80105fb0:	83 ec 08             	sub    $0x8,%esp
  exit();
80105fb3:	e8 73 e4 ff ff       	call   8010442b <exit>
  return 0;  // not reached
80105fb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fbd:	c9                   	leave  
80105fbe:	c3                   	ret    

80105fbf <sys_wait>:

int
sys_wait(void)
{
80105fbf:	55                   	push   %ebp
80105fc0:	89 e5                	mov    %esp,%ebp
80105fc2:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105fc5:	e8 7b e5 ff ff       	call   80104545 <wait>
}
80105fca:	c9                   	leave  
80105fcb:	c3                   	ret    

80105fcc <sys_kill>:

int
sys_kill(void)
{
80105fcc:	55                   	push   %ebp
80105fcd:	89 e5                	mov    %esp,%ebp
80105fcf:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105fd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fe0:	e8 cf f0 ff ff       	call   801050b4 <argint>
80105fe5:	85 c0                	test   %eax,%eax
80105fe7:	79 07                	jns    80105ff0 <sys_kill+0x24>
    return -1;
80105fe9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fee:	eb 0b                	jmp    80105ffb <sys_kill+0x2f>
  return kill(pid);
80105ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff3:	89 04 24             	mov    %eax,(%esp)
80105ff6:	e8 0f e9 ff ff       	call   8010490a <kill>
}
80105ffb:	c9                   	leave  
80105ffc:	c3                   	ret    

80105ffd <sys_getpid>:

int
sys_getpid(void)
{
80105ffd:	55                   	push   %ebp
80105ffe:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106000:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106006:	8b 40 10             	mov    0x10(%eax),%eax
}
80106009:	5d                   	pop    %ebp
8010600a:	c3                   	ret    

8010600b <sys_sbrk>:

int
sys_sbrk(void)
{
8010600b:	55                   	push   %ebp
8010600c:	89 e5                	mov    %esp,%ebp
8010600e:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106011:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106014:	89 44 24 04          	mov    %eax,0x4(%esp)
80106018:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010601f:	e8 90 f0 ff ff       	call   801050b4 <argint>
80106024:	85 c0                	test   %eax,%eax
80106026:	79 07                	jns    8010602f <sys_sbrk+0x24>
    return -1;
80106028:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602d:	eb 24                	jmp    80106053 <sys_sbrk+0x48>
  addr = proc->sz;
8010602f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106035:	8b 00                	mov    (%eax),%eax
80106037:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010603a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603d:	89 04 24             	mov    %eax,(%esp)
80106040:	e8 df e1 ff ff       	call   80104224 <growproc>
80106045:	85 c0                	test   %eax,%eax
80106047:	79 07                	jns    80106050 <sys_sbrk+0x45>
    return -1;
80106049:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604e:	eb 03                	jmp    80106053 <sys_sbrk+0x48>
  return addr;
80106050:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106053:	c9                   	leave  
80106054:	c3                   	ret    

80106055 <sys_sleep>:

int
sys_sleep(void)
{
80106055:	55                   	push   %ebp
80106056:	89 e5                	mov    %esp,%ebp
80106058:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
8010605b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010605e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106062:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106069:	e8 46 f0 ff ff       	call   801050b4 <argint>
8010606e:	85 c0                	test   %eax,%eax
80106070:	79 07                	jns    80106079 <sys_sleep+0x24>
    return -1;
80106072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106077:	eb 6c                	jmp    801060e5 <sys_sleep+0x90>
  acquire(&tickslock);
80106079:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80106080:	e8 a6 ea ff ff       	call   80104b2b <acquire>
  ticks0 = ticks;
80106085:	a1 c0 2a 11 80       	mov    0x80112ac0,%eax
8010608a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010608d:	eb 34                	jmp    801060c3 <sys_sleep+0x6e>
    if(proc->killed){
8010608f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106095:	8b 40 24             	mov    0x24(%eax),%eax
80106098:	85 c0                	test   %eax,%eax
8010609a:	74 13                	je     801060af <sys_sleep+0x5a>
      release(&tickslock);
8010609c:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801060a3:	e8 e5 ea ff ff       	call   80104b8d <release>
      return -1;
801060a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ad:	eb 36                	jmp    801060e5 <sys_sleep+0x90>
    }
    sleep(&ticks, &tickslock);
801060af:	c7 44 24 04 80 22 11 	movl   $0x80112280,0x4(%esp)
801060b6:	80 
801060b7:	c7 04 24 c0 2a 11 80 	movl   $0x80112ac0,(%esp)
801060be:	e8 40 e7 ff ff       	call   80104803 <sleep>
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801060c3:	a1 c0 2a 11 80       	mov    0x80112ac0,%eax
801060c8:	89 c2                	mov    %eax,%edx
801060ca:	2b 55 f4             	sub    -0xc(%ebp),%edx
801060cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d0:	39 c2                	cmp    %eax,%edx
801060d2:	72 bb                	jb     8010608f <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801060d4:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801060db:	e8 ad ea ff ff       	call   80104b8d <release>
  return 0;
801060e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060e5:	c9                   	leave  
801060e6:	c3                   	ret    

801060e7 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801060e7:	55                   	push   %ebp
801060e8:	89 e5                	mov    %esp,%ebp
801060ea:	83 ec 28             	sub    $0x28,%esp
  uint xticks;
  
  acquire(&tickslock);
801060ed:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801060f4:	e8 32 ea ff ff       	call   80104b2b <acquire>
  xticks = ticks;
801060f9:	a1 c0 2a 11 80       	mov    0x80112ac0,%eax
801060fe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106101:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80106108:	e8 80 ea ff ff       	call   80104b8d <release>
  return xticks;
8010610d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106110:	c9                   	leave  
80106111:	c3                   	ret    

80106112 <sys_getppid>:

// USER DEFINED SYS CALL
int
sys_getppid(void)
{ 
80106112:	55                   	push   %ebp
80106113:	89 e5                	mov    %esp,%ebp
  if(proc->parent == 0)
80106115:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010611b:	8b 40 14             	mov    0x14(%eax),%eax
8010611e:	85 c0                	test   %eax,%eax
80106120:	75 07                	jne    80106129 <sys_getppid+0x17>
      return (0);
80106122:	b8 00 00 00 00       	mov    $0x0,%eax
80106127:	eb 0c                	jmp    80106135 <sys_getppid+0x23>

  return proc->parent->pid;
80106129:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010612f:	8b 40 14             	mov    0x14(%eax),%eax
80106132:	8b 40 10             	mov    0x10(%eax),%eax
}
80106135:	5d                   	pop    %ebp
80106136:	c3                   	ret    

80106137 <sys_icount>:

// USER DEFINED SYS CALL
int
sys_icount(void)
{
80106137:	55                   	push   %ebp
80106138:	89 e5                	mov    %esp,%ebp
8010613a:	83 ec 10             	sub    $0x10,%esp
  int cnt = 0;//kbd_int_count;
8010613d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  return cnt;
80106144:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106147:	c9                   	leave  
80106148:	c3                   	ret    

80106149 <sys_signal>:

int
sys_signal(void)
{
80106149:	55                   	push   %ebp
8010614a:	89 e5                	mov    %esp,%ebp
8010614c:	83 ec 28             	sub    $0x28,%esp
  int signum;
  sighandler_t signal_handler;
  
  if(argint(0, &signum) < 0)
8010614f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106152:	89 44 24 04          	mov    %eax,0x4(%esp)
80106156:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010615d:	e8 52 ef ff ff       	call   801050b4 <argint>
80106162:	85 c0                	test   %eax,%eax
80106164:	79 07                	jns    8010616d <sys_signal+0x24>
    return -1;
80106166:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616b:	eb 46                	jmp    801061b3 <sys_signal+0x6a>
  if((signum != 0) && (signum != 1))
8010616d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106170:	85 c0                	test   %eax,%eax
80106172:	74 0f                	je     80106183 <sys_signal+0x3a>
80106174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106177:	83 f8 01             	cmp    $0x1,%eax
8010617a:	74 07                	je     80106183 <sys_signal+0x3a>
    return -1;
8010617c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106181:	eb 30                	jmp    801061b3 <sys_signal+0x6a>
  if(argsig(1, &signal_handler) < 0)  // Get 2nd argument
80106183:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106186:	89 44 24 04          	mov    %eax,0x4(%esp)
8010618a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106191:	e8 4c ef ff ff       	call   801050e2 <argsig>
80106196:	85 c0                	test   %eax,%eax
80106198:	79 07                	jns    801061a1 <sys_signal+0x58>
    return -1;
8010619a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010619f:	eb 12                	jmp    801061b3 <sys_signal+0x6a>
      
  return (signal(signum, signal_handler));
801061a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801061a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a7:	89 54 24 04          	mov    %edx,0x4(%esp)
801061ab:	89 04 24             	mov    %eax,(%esp)
801061ae:	e8 cd e8 ff ff       	call   80104a80 <signal>
801061b3:	c9                   	leave  
801061b4:	c3                   	ret    
801061b5:	66 90                	xchg   %ax,%ax
801061b7:	90                   	nop

801061b8 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801061b8:	55                   	push   %ebp
801061b9:	89 e5                	mov    %esp,%ebp
801061bb:	83 ec 08             	sub    $0x8,%esp
801061be:	8b 45 08             	mov    0x8(%ebp),%eax
801061c1:	8b 55 0c             	mov    0xc(%ebp),%edx
801061c4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801061c8:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801061cb:	8a 45 f8             	mov    -0x8(%ebp),%al
801061ce:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061d1:	ee                   	out    %al,(%dx)
}
801061d2:	c9                   	leave  
801061d3:	c3                   	ret    

801061d4 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801061d4:	55                   	push   %ebp
801061d5:	89 e5                	mov    %esp,%ebp
801061d7:	83 ec 18             	sub    $0x18,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801061da:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
801061e1:	00 
801061e2:	c7 04 24 43 00 00 00 	movl   $0x43,(%esp)
801061e9:	e8 ca ff ff ff       	call   801061b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801061ee:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
801061f5:	00 
801061f6:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
801061fd:	e8 b6 ff ff ff       	call   801061b8 <outb>
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106202:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
80106209:	00 
8010620a:	c7 04 24 40 00 00 00 	movl   $0x40,(%esp)
80106211:	e8 a2 ff ff ff       	call   801061b8 <outb>
  picenable(IRQ_TIMER);
80106216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010621d:	e8 62 d8 ff ff       	call   80103a84 <picenable>
}
80106222:	c9                   	leave  
80106223:	c3                   	ret    

80106224 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106224:	1e                   	push   %ds
  pushl %es
80106225:	06                   	push   %es
  pushl %fs
80106226:	0f a0                	push   %fs
  pushl %gs
80106228:	0f a8                	push   %gs
  pushal
8010622a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010622b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010622f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106231:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106233:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106237:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106239:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010623b:	54                   	push   %esp
  call trap
8010623c:	e8 c5 01 00 00       	call   80106406 <trap>
  addl $4, %esp
80106241:	83 c4 04             	add    $0x4,%esp

80106244 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106244:	61                   	popa   
  popl %gs
80106245:	0f a9                	pop    %gs
  popl %fs
80106247:	0f a1                	pop    %fs
  popl %es
80106249:	07                   	pop    %es
  popl %ds
8010624a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010624b:	83 c4 08             	add    $0x8,%esp
  iret
8010624e:	cf                   	iret   
8010624f:	90                   	nop

80106250 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106250:	55                   	push   %ebp
80106251:	89 e5                	mov    %esp,%ebp
80106253:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106256:	8b 45 0c             	mov    0xc(%ebp),%eax
80106259:	48                   	dec    %eax
8010625a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010625e:	8b 45 08             	mov    0x8(%ebp),%eax
80106261:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106265:	8b 45 08             	mov    0x8(%ebp),%eax
80106268:	c1 e8 10             	shr    $0x10,%eax
8010626b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010626f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106272:	0f 01 18             	lidtl  (%eax)
}
80106275:	c9                   	leave  
80106276:	c3                   	ret    

80106277 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106277:	55                   	push   %ebp
80106278:	89 e5                	mov    %esp,%ebp
8010627a:	53                   	push   %ebx
8010627b:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010627e:	0f 20 d3             	mov    %cr2,%ebx
80106281:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  return val;
80106284:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80106287:	83 c4 10             	add    $0x10,%esp
8010628a:	5b                   	pop    %ebx
8010628b:	5d                   	pop    %ebp
8010628c:	c3                   	ret    

8010628d <tvinit>:
int kbd_int_count;


void
tvinit(void)
{
8010628d:	55                   	push   %ebp
8010628e:	89 e5                	mov    %esp,%ebp
80106290:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106293:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010629a:	e9 b8 00 00 00       	jmp    80106357 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010629f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a2:	8b 04 85 a4 b0 10 80 	mov    -0x7fef4f5c(,%eax,4),%eax
801062a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062ac:	66 89 04 d5 c0 22 11 	mov    %ax,-0x7feedd40(,%edx,8)
801062b3:	80 
801062b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b7:	66 c7 04 c5 c2 22 11 	movw   $0x8,-0x7feedd3e(,%eax,8)
801062be:	80 08 00 
801062c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062c4:	8a 14 c5 c4 22 11 80 	mov    -0x7feedd3c(,%eax,8),%dl
801062cb:	83 e2 e0             	and    $0xffffffe0,%edx
801062ce:	88 14 c5 c4 22 11 80 	mov    %dl,-0x7feedd3c(,%eax,8)
801062d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d8:	8a 14 c5 c4 22 11 80 	mov    -0x7feedd3c(,%eax,8),%dl
801062df:	83 e2 1f             	and    $0x1f,%edx
801062e2:	88 14 c5 c4 22 11 80 	mov    %dl,-0x7feedd3c(,%eax,8)
801062e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ec:	8a 14 c5 c5 22 11 80 	mov    -0x7feedd3b(,%eax,8),%dl
801062f3:	83 e2 f0             	and    $0xfffffff0,%edx
801062f6:	83 ca 0e             	or     $0xe,%edx
801062f9:	88 14 c5 c5 22 11 80 	mov    %dl,-0x7feedd3b(,%eax,8)
80106300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106303:	8a 14 c5 c5 22 11 80 	mov    -0x7feedd3b(,%eax,8),%dl
8010630a:	83 e2 ef             	and    $0xffffffef,%edx
8010630d:	88 14 c5 c5 22 11 80 	mov    %dl,-0x7feedd3b(,%eax,8)
80106314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106317:	8a 14 c5 c5 22 11 80 	mov    -0x7feedd3b(,%eax,8),%dl
8010631e:	83 e2 9f             	and    $0xffffff9f,%edx
80106321:	88 14 c5 c5 22 11 80 	mov    %dl,-0x7feedd3b(,%eax,8)
80106328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632b:	8a 14 c5 c5 22 11 80 	mov    -0x7feedd3b(,%eax,8),%dl
80106332:	83 ca 80             	or     $0xffffff80,%edx
80106335:	88 14 c5 c5 22 11 80 	mov    %dl,-0x7feedd3b(,%eax,8)
8010633c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633f:	8b 04 85 a4 b0 10 80 	mov    -0x7fef4f5c(,%eax,4),%eax
80106346:	c1 e8 10             	shr    $0x10,%eax
80106349:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010634c:	66 89 04 d5 c6 22 11 	mov    %ax,-0x7feedd3a(,%edx,8)
80106353:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106354:	ff 45 f4             	incl   -0xc(%ebp)
80106357:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010635e:	0f 8e 3b ff ff ff    	jle    8010629f <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106364:	a1 a4 b1 10 80       	mov    0x8010b1a4,%eax
80106369:	66 a3 c0 24 11 80    	mov    %ax,0x801124c0
8010636f:	66 c7 05 c2 24 11 80 	movw   $0x8,0x801124c2
80106376:	08 00 
80106378:	a0 c4 24 11 80       	mov    0x801124c4,%al
8010637d:	83 e0 e0             	and    $0xffffffe0,%eax
80106380:	a2 c4 24 11 80       	mov    %al,0x801124c4
80106385:	a0 c4 24 11 80       	mov    0x801124c4,%al
8010638a:	83 e0 1f             	and    $0x1f,%eax
8010638d:	a2 c4 24 11 80       	mov    %al,0x801124c4
80106392:	a0 c5 24 11 80       	mov    0x801124c5,%al
80106397:	83 c8 0f             	or     $0xf,%eax
8010639a:	a2 c5 24 11 80       	mov    %al,0x801124c5
8010639f:	a0 c5 24 11 80       	mov    0x801124c5,%al
801063a4:	83 e0 ef             	and    $0xffffffef,%eax
801063a7:	a2 c5 24 11 80       	mov    %al,0x801124c5
801063ac:	a0 c5 24 11 80       	mov    0x801124c5,%al
801063b1:	83 c8 60             	or     $0x60,%eax
801063b4:	a2 c5 24 11 80       	mov    %al,0x801124c5
801063b9:	a0 c5 24 11 80       	mov    0x801124c5,%al
801063be:	83 c8 80             	or     $0xffffff80,%eax
801063c1:	a2 c5 24 11 80       	mov    %al,0x801124c5
801063c6:	a1 a4 b1 10 80       	mov    0x8010b1a4,%eax
801063cb:	c1 e8 10             	shr    $0x10,%eax
801063ce:	66 a3 c6 24 11 80    	mov    %ax,0x801124c6
  
  initlock(&tickslock, "time");
801063d4:	c7 44 24 04 04 86 10 	movl   $0x80108604,0x4(%esp)
801063db:	80 
801063dc:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801063e3:	e8 22 e7 ff ff       	call   80104b0a <initlock>
}
801063e8:	c9                   	leave  
801063e9:	c3                   	ret    

801063ea <idtinit>:

void
idtinit(void)
{
801063ea:	55                   	push   %ebp
801063eb:	89 e5                	mov    %esp,%ebp
801063ed:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801063f0:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801063f7:	00 
801063f8:	c7 04 24 c0 22 11 80 	movl   $0x801122c0,(%esp)
801063ff:	e8 4c fe ff ff       	call   80106250 <lidt>
}
80106404:	c9                   	leave  
80106405:	c3                   	ret    

80106406 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106406:	55                   	push   %ebp
80106407:	89 e5                	mov    %esp,%ebp
80106409:	57                   	push   %edi
8010640a:	56                   	push   %esi
8010640b:	53                   	push   %ebx
8010640c:	83 ec 3c             	sub    $0x3c,%esp
  if(tf->trapno == T_SYSCALL){
8010640f:	8b 45 08             	mov    0x8(%ebp),%eax
80106412:	8b 40 30             	mov    0x30(%eax),%eax
80106415:	83 f8 40             	cmp    $0x40,%eax
80106418:	75 3e                	jne    80106458 <trap+0x52>
    if(proc->killed)
8010641a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106420:	8b 40 24             	mov    0x24(%eax),%eax
80106423:	85 c0                	test   %eax,%eax
80106425:	74 05                	je     8010642c <trap+0x26>
      exit();
80106427:	e8 ff df ff ff       	call   8010442b <exit>
    proc->tf = tf;
8010642c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106432:	8b 55 08             	mov    0x8(%ebp),%edx
80106435:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106438:	e8 a0 ed ff ff       	call   801051dd <syscall>
    if(proc->killed)
8010643d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106443:	8b 40 24             	mov    0x24(%eax),%eax
80106446:	85 c0                	test   %eax,%eax
80106448:	0f 84 80 02 00 00    	je     801066ce <trap+0x2c8>
      exit();
8010644e:	e8 d8 df ff ff       	call   8010442b <exit>
    return;
80106453:	e9 76 02 00 00       	jmp    801066ce <trap+0x2c8>
  }

  switch(tf->trapno){
80106458:	8b 45 08             	mov    0x8(%ebp),%eax
8010645b:	8b 40 30             	mov    0x30(%eax),%eax
8010645e:	83 e8 20             	sub    $0x20,%eax
80106461:	83 f8 1f             	cmp    $0x1f,%eax
80106464:	0f 87 c2 00 00 00    	ja     8010652c <trap+0x126>
8010646a:	8b 04 85 e8 86 10 80 	mov    -0x7fef7918(,%eax,4),%eax
80106471:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106473:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106479:	8a 00                	mov    (%eax),%al
8010647b:	84 c0                	test   %al,%al
8010647d:	75 2f                	jne    801064ae <trap+0xa8>
      acquire(&tickslock);
8010647f:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
80106486:	e8 a0 e6 ff ff       	call   80104b2b <acquire>
      ticks++;
8010648b:	a1 c0 2a 11 80       	mov    0x80112ac0,%eax
80106490:	40                   	inc    %eax
80106491:	a3 c0 2a 11 80       	mov    %eax,0x80112ac0
      wakeup(&ticks);
80106496:	c7 04 24 c0 2a 11 80 	movl   $0x80112ac0,(%esp)
8010649d:	e8 3d e4 ff ff       	call   801048df <wakeup>
      release(&tickslock);
801064a2:	c7 04 24 80 22 11 80 	movl   $0x80112280,(%esp)
801064a9:	e8 df e6 ff ff       	call   80104b8d <release>
    }
    lapiceoi();
801064ae:	e8 ce c9 ff ff       	call   80102e81 <lapiceoi>
    break;
801064b3:	e9 92 01 00 00       	jmp    8010664a <trap+0x244>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801064b8:	e8 dd c1 ff ff       	call   8010269a <ideintr>
    lapiceoi();
801064bd:	e8 bf c9 ff ff       	call   80102e81 <lapiceoi>
    break;
801064c2:	e9 83 01 00 00       	jmp    8010664a <trap+0x244>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801064c7:	e8 97 c7 ff ff       	call   80102c63 <kbdintr>
    lapiceoi();
801064cc:	e8 b0 c9 ff ff       	call   80102e81 <lapiceoi>
    break;
801064d1:	e9 74 01 00 00       	jmp    8010664a <trap+0x244>
  case T_IRQ0 + IRQ_COM1:
    kbd_int_count++;
801064d6:	a1 c4 2a 11 80       	mov    0x80112ac4,%eax
801064db:	40                   	inc    %eax
801064dc:	a3 c4 2a 11 80       	mov    %eax,0x80112ac4
    uartintr();
801064e1:	e8 e6 03 00 00       	call   801068cc <uartintr>
    lapiceoi();
801064e6:	e8 96 c9 ff ff       	call   80102e81 <lapiceoi>
    break;
801064eb:	e9 5a 01 00 00       	jmp    8010664a <trap+0x244>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
            cpu->id, tf->cs, tf->eip);
801064f0:	8b 45 08             	mov    0x8(%ebp),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801064f3:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801064f6:	8b 45 08             	mov    0x8(%ebp),%eax
801064f9:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801064fc:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801064ff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106505:	8a 00                	mov    (%eax),%al
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106507:	0f b6 c0             	movzbl %al,%eax
8010650a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010650e:	89 54 24 08          	mov    %edx,0x8(%esp)
80106512:	89 44 24 04          	mov    %eax,0x4(%esp)
80106516:	c7 04 24 0c 86 10 80 	movl   $0x8010860c,(%esp)
8010651d:	e8 7f 9e ff ff       	call   801003a1 <cprintf>
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106522:	e8 5a c9 ff ff       	call   80102e81 <lapiceoi>
    break;
80106527:	e9 1e 01 00 00       	jmp    8010664a <trap+0x244>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010652c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106532:	85 c0                	test   %eax,%eax
80106534:	74 10                	je     80106546 <trap+0x140>
80106536:	8b 45 08             	mov    0x8(%ebp),%eax
80106539:	8b 40 3c             	mov    0x3c(%eax),%eax
8010653c:	0f b7 c0             	movzwl %ax,%eax
8010653f:	83 e0 03             	and    $0x3,%eax
80106542:	85 c0                	test   %eax,%eax
80106544:	75 45                	jne    8010658b <trap+0x185>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106546:	e8 2c fd ff ff       	call   80106277 <rcr2>
              tf->trapno, cpu->id, tf->eip, rcr2());
8010654b:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010654e:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106551:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106558:	8a 12                	mov    (%edx),%dl
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010655a:	0f b6 ca             	movzbl %dl,%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010655d:	8b 55 08             	mov    0x8(%ebp),%edx
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106560:	8b 52 30             	mov    0x30(%edx),%edx
80106563:	89 44 24 10          	mov    %eax,0x10(%esp)
80106567:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
8010656b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010656f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106573:	c7 04 24 30 86 10 80 	movl   $0x80108630,(%esp)
8010657a:	e8 22 9e ff ff       	call   801003a1 <cprintf>
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
8010657f:	c7 04 24 62 86 10 80 	movl   $0x80108662,(%esp)
80106586:	e8 ab 9f ff ff       	call   80100536 <panic>
    }
    // In user space, assume process misbehaved.
    if(tf->trapno == T_PGFLT)
8010658b:	8b 45 08             	mov    0x8(%ebp),%eax
8010658e:	8b 40 30             	mov    0x30(%eax),%eax
80106591:	83 f8 0e             	cmp    $0xe,%eax
80106594:	0f 85 b0 00 00 00    	jne    8010664a <trap+0x244>
    {    
        if(proc->sig_flag[0] == 0)
8010659a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065a0:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
801065a6:	85 c0                	test   %eax,%eax
801065a8:	75 20                	jne    801065ca <trap+0x1c4>
        {
            cprintf("User-defined handler called!\n");
801065aa:	c7 04 24 67 86 10 80 	movl   $0x80108667,(%esp)
801065b1:	e8 eb 9d ff ff       	call   801003a1 <cprintf>
            proc->signal_handler[0](SIGSEGV);
801065b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065bc:	8b 40 7c             	mov    0x7c(%eax),%eax
801065bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065c6:	ff d0                	call   *%eax
801065c8:	eb 0c                	jmp    801065d6 <trap+0x1d0>
        }
        else
            cprintf("Default handler called!\n");
801065ca:	c7 04 24 85 86 10 80 	movl   $0x80108685,(%esp)
801065d1:	e8 cb 9d ff ff       	call   801003a1 <cprintf>
            
        cprintf("\n\npid %d %s: trap %d err %d on cpu %d "
801065d6:	e8 9c fc ff ff       	call   80106277 <rcr2>
801065db:	89 c2                	mov    %eax,%edx
                "eip 0x%x addr 0x%x--kill proc\n",
                proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065dd:	8b 45 08             	mov    0x8(%ebp),%eax
            proc->signal_handler[0](SIGSEGV);
        }
        else
            cprintf("Default handler called!\n");
            
        cprintf("\n\npid %d %s: trap %d err %d on cpu %d "
801065e0:	8b 78 38             	mov    0x38(%eax),%edi
                "eip 0x%x addr 0x%x--kill proc\n",
                proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065e3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801065e9:	8a 00                	mov    (%eax),%al
            proc->signal_handler[0](SIGSEGV);
        }
        else
            cprintf("Default handler called!\n");
            
        cprintf("\n\npid %d %s: trap %d err %d on cpu %d "
801065eb:	0f b6 f0             	movzbl %al,%esi
                "eip 0x%x addr 0x%x--kill proc\n",
                proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065ee:	8b 45 08             	mov    0x8(%ebp),%eax
            proc->signal_handler[0](SIGSEGV);
        }
        else
            cprintf("Default handler called!\n");
            
        cprintf("\n\npid %d %s: trap %d err %d on cpu %d "
801065f1:	8b 58 34             	mov    0x34(%eax),%ebx
                "eip 0x%x addr 0x%x--kill proc\n",
                proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065f4:	8b 45 08             	mov    0x8(%ebp),%eax
            proc->signal_handler[0](SIGSEGV);
        }
        else
            cprintf("Default handler called!\n");
            
        cprintf("\n\npid %d %s: trap %d err %d on cpu %d "
801065f7:	8b 48 30             	mov    0x30(%eax),%ecx
                "eip 0x%x addr 0x%x--kill proc\n",
                proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801065fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106600:	83 c0 6c             	add    $0x6c,%eax
80106603:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106606:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
            proc->signal_handler[0](SIGSEGV);
        }
        else
            cprintf("Default handler called!\n");
            
        cprintf("\n\npid %d %s: trap %d err %d on cpu %d "
8010660c:	8b 40 10             	mov    0x10(%eax),%eax
8010660f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80106613:	89 7c 24 18          	mov    %edi,0x18(%esp)
80106617:	89 74 24 14          	mov    %esi,0x14(%esp)
8010661b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010661f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106623:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106626:	89 54 24 08          	mov    %edx,0x8(%esp)
8010662a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010662e:	c7 04 24 a0 86 10 80 	movl   $0x801086a0,(%esp)
80106635:	e8 67 9d ff ff       	call   801003a1 <cprintf>
                "eip 0x%x addr 0x%x--kill proc\n",
                proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
                rcr2());
        proc->killed = 1;
8010663a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106640:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106647:	eb 01                	jmp    8010664a <trap+0x244>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106649:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010664a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106650:	85 c0                	test   %eax,%eax
80106652:	74 23                	je     80106677 <trap+0x271>
80106654:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010665a:	8b 40 24             	mov    0x24(%eax),%eax
8010665d:	85 c0                	test   %eax,%eax
8010665f:	74 16                	je     80106677 <trap+0x271>
80106661:	8b 45 08             	mov    0x8(%ebp),%eax
80106664:	8b 40 3c             	mov    0x3c(%eax),%eax
80106667:	0f b7 c0             	movzwl %ax,%eax
8010666a:	83 e0 03             	and    $0x3,%eax
8010666d:	83 f8 03             	cmp    $0x3,%eax
80106670:	75 05                	jne    80106677 <trap+0x271>
    exit();
80106672:	e8 b4 dd ff ff       	call   8010442b <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106677:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010667d:	85 c0                	test   %eax,%eax
8010667f:	74 1e                	je     8010669f <trap+0x299>
80106681:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106687:	8b 40 0c             	mov    0xc(%eax),%eax
8010668a:	83 f8 04             	cmp    $0x4,%eax
8010668d:	75 10                	jne    8010669f <trap+0x299>
8010668f:	8b 45 08             	mov    0x8(%ebp),%eax
80106692:	8b 40 30             	mov    0x30(%eax),%eax
80106695:	83 f8 20             	cmp    $0x20,%eax
80106698:	75 05                	jne    8010669f <trap+0x299>
    yield();
8010669a:	e8 06 e1 ff ff       	call   801047a5 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010669f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a5:	85 c0                	test   %eax,%eax
801066a7:	74 26                	je     801066cf <trap+0x2c9>
801066a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066af:	8b 40 24             	mov    0x24(%eax),%eax
801066b2:	85 c0                	test   %eax,%eax
801066b4:	74 19                	je     801066cf <trap+0x2c9>
801066b6:	8b 45 08             	mov    0x8(%ebp),%eax
801066b9:	8b 40 3c             	mov    0x3c(%eax),%eax
801066bc:	0f b7 c0             	movzwl %ax,%eax
801066bf:	83 e0 03             	and    $0x3,%eax
801066c2:	83 f8 03             	cmp    $0x3,%eax
801066c5:	75 08                	jne    801066cf <trap+0x2c9>
    exit();
801066c7:	e8 5f dd ff ff       	call   8010442b <exit>
801066cc:	eb 01                	jmp    801066cf <trap+0x2c9>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
801066ce:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
801066cf:	83 c4 3c             	add    $0x3c,%esp
801066d2:	5b                   	pop    %ebx
801066d3:	5e                   	pop    %esi
801066d4:	5f                   	pop    %edi
801066d5:	5d                   	pop    %ebp
801066d6:	c3                   	ret    
801066d7:	90                   	nop

801066d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801066d8:	55                   	push   %ebp
801066d9:	89 e5                	mov    %esp,%ebp
801066db:	53                   	push   %ebx
801066dc:	83 ec 14             	sub    $0x14,%esp
801066df:	8b 45 08             	mov    0x8(%ebp),%eax
801066e2:	66 89 45 e8          	mov    %ax,-0x18(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801066e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801066e9:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
801066ed:	66 8b 55 ea          	mov    -0x16(%ebp),%dx
801066f1:	ec                   	in     (%dx),%al
801066f2:	88 c3                	mov    %al,%bl
801066f4:	88 5d fb             	mov    %bl,-0x5(%ebp)
  return data;
801066f7:	8a 45 fb             	mov    -0x5(%ebp),%al
}
801066fa:	83 c4 14             	add    $0x14,%esp
801066fd:	5b                   	pop    %ebx
801066fe:	5d                   	pop    %ebp
801066ff:	c3                   	ret    

80106700 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106700:	55                   	push   %ebp
80106701:	89 e5                	mov    %esp,%ebp
80106703:	83 ec 08             	sub    $0x8,%esp
80106706:	8b 45 08             	mov    0x8(%ebp),%eax
80106709:	8b 55 0c             	mov    0xc(%ebp),%edx
8010670c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106710:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106713:	8a 45 f8             	mov    -0x8(%ebp),%al
80106716:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106719:	ee                   	out    %al,(%dx)
}
8010671a:	c9                   	leave  
8010671b:	c3                   	ret    

8010671c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010671c:	55                   	push   %ebp
8010671d:	89 e5                	mov    %esp,%ebp
8010671f:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106722:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106729:	00 
8010672a:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106731:	e8 ca ff ff ff       	call   80106700 <outb>
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106736:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
8010673d:	00 
8010673e:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106745:	e8 b6 ff ff ff       	call   80106700 <outb>
  outb(COM1+0, 115200/9600);
8010674a:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106751:	00 
80106752:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106759:	e8 a2 ff ff ff       	call   80106700 <outb>
  outb(COM1+1, 0);
8010675e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106765:	00 
80106766:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010676d:	e8 8e ff ff ff       	call   80106700 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106772:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106779:	00 
8010677a:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106781:	e8 7a ff ff ff       	call   80106700 <outb>
  outb(COM1+4, 0);
80106786:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010678d:	00 
8010678e:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106795:	e8 66 ff ff ff       	call   80106700 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010679a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801067a1:	00 
801067a2:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801067a9:	e8 52 ff ff ff       	call   80106700 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801067ae:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801067b5:	e8 1e ff ff ff       	call   801066d8 <inb>
801067ba:	3c ff                	cmp    $0xff,%al
801067bc:	74 69                	je     80106827 <uartinit+0x10b>
    return;
  uart = 1;
801067be:	c7 05 6c b6 10 80 01 	movl   $0x1,0x8010b66c
801067c5:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801067c8:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801067cf:	e8 04 ff ff ff       	call   801066d8 <inb>
  inb(COM1+0);
801067d4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801067db:	e8 f8 fe ff ff       	call   801066d8 <inb>
  picenable(IRQ_COM1);
801067e0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801067e7:	e8 98 d2 ff ff       	call   80103a84 <picenable>
  ioapicenable(IRQ_COM1, 0);
801067ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801067f3:	00 
801067f4:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801067fb:	e8 19 c1 ff ff       	call   80102919 <ioapicenable>
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106800:	c7 45 f4 68 87 10 80 	movl   $0x80108768,-0xc(%ebp)
80106807:	eb 13                	jmp    8010681c <uartinit+0x100>
    uartputc(*p);
80106809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010680c:	8a 00                	mov    (%eax),%al
8010680e:	0f be c0             	movsbl %al,%eax
80106811:	89 04 24             	mov    %eax,(%esp)
80106814:	e8 11 00 00 00       	call   8010682a <uartputc>
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106819:	ff 45 f4             	incl   -0xc(%ebp)
8010681c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681f:	8a 00                	mov    (%eax),%al
80106821:	84 c0                	test   %al,%al
80106823:	75 e4                	jne    80106809 <uartinit+0xed>
80106825:	eb 01                	jmp    80106828 <uartinit+0x10c>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106827:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106828:	c9                   	leave  
80106829:	c3                   	ret    

8010682a <uartputc>:

void
uartputc(int c)
{
8010682a:	55                   	push   %ebp
8010682b:	89 e5                	mov    %esp,%ebp
8010682d:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106830:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106835:	85 c0                	test   %eax,%eax
80106837:	74 4c                	je     80106885 <uartputc+0x5b>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106839:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106840:	eb 0f                	jmp    80106851 <uartputc+0x27>
    microdelay(10);
80106842:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106849:	e8 58 c6 ff ff       	call   80102ea6 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010684e:	ff 45 f4             	incl   -0xc(%ebp)
80106851:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106855:	7f 16                	jg     8010686d <uartputc+0x43>
80106857:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010685e:	e8 75 fe ff ff       	call   801066d8 <inb>
80106863:	0f b6 c0             	movzbl %al,%eax
80106866:	83 e0 20             	and    $0x20,%eax
80106869:	85 c0                	test   %eax,%eax
8010686b:	74 d5                	je     80106842 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010686d:	8b 45 08             	mov    0x8(%ebp),%eax
80106870:	0f b6 c0             	movzbl %al,%eax
80106873:	89 44 24 04          	mov    %eax,0x4(%esp)
80106877:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010687e:	e8 7d fe ff ff       	call   80106700 <outb>
80106883:	eb 01                	jmp    80106886 <uartputc+0x5c>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106885:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106886:	c9                   	leave  
80106887:	c3                   	ret    

80106888 <uartgetc>:

static int
uartgetc(void)
{
80106888:	55                   	push   %ebp
80106889:	89 e5                	mov    %esp,%ebp
8010688b:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010688e:	a1 6c b6 10 80       	mov    0x8010b66c,%eax
80106893:	85 c0                	test   %eax,%eax
80106895:	75 07                	jne    8010689e <uartgetc+0x16>
    return -1;
80106897:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010689c:	eb 2c                	jmp    801068ca <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010689e:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801068a5:	e8 2e fe ff ff       	call   801066d8 <inb>
801068aa:	0f b6 c0             	movzbl %al,%eax
801068ad:	83 e0 01             	and    $0x1,%eax
801068b0:	85 c0                	test   %eax,%eax
801068b2:	75 07                	jne    801068bb <uartgetc+0x33>
    return -1;
801068b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068b9:	eb 0f                	jmp    801068ca <uartgetc+0x42>
  return inb(COM1+0);
801068bb:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801068c2:	e8 11 fe ff ff       	call   801066d8 <inb>
801068c7:	0f b6 c0             	movzbl %al,%eax
}
801068ca:	c9                   	leave  
801068cb:	c3                   	ret    

801068cc <uartintr>:

void
uartintr(void)
{
801068cc:	55                   	push   %ebp
801068cd:	89 e5                	mov    %esp,%ebp
801068cf:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801068d2:	c7 04 24 88 68 10 80 	movl   $0x80106888,(%esp)
801068d9:	e8 b2 9e ff ff       	call   80100790 <consoleintr>
}
801068de:	c9                   	leave  
801068df:	c3                   	ret    

801068e0 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801068e0:	6a 00                	push   $0x0
  pushl $0
801068e2:	6a 00                	push   $0x0
  jmp alltraps
801068e4:	e9 3b f9 ff ff       	jmp    80106224 <alltraps>

801068e9 <vector1>:
.globl vector1
vector1:
  pushl $0
801068e9:	6a 00                	push   $0x0
  pushl $1
801068eb:	6a 01                	push   $0x1
  jmp alltraps
801068ed:	e9 32 f9 ff ff       	jmp    80106224 <alltraps>

801068f2 <vector2>:
.globl vector2
vector2:
  pushl $0
801068f2:	6a 00                	push   $0x0
  pushl $2
801068f4:	6a 02                	push   $0x2
  jmp alltraps
801068f6:	e9 29 f9 ff ff       	jmp    80106224 <alltraps>

801068fb <vector3>:
.globl vector3
vector3:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $3
801068fd:	6a 03                	push   $0x3
  jmp alltraps
801068ff:	e9 20 f9 ff ff       	jmp    80106224 <alltraps>

80106904 <vector4>:
.globl vector4
vector4:
  pushl $0
80106904:	6a 00                	push   $0x0
  pushl $4
80106906:	6a 04                	push   $0x4
  jmp alltraps
80106908:	e9 17 f9 ff ff       	jmp    80106224 <alltraps>

8010690d <vector5>:
.globl vector5
vector5:
  pushl $0
8010690d:	6a 00                	push   $0x0
  pushl $5
8010690f:	6a 05                	push   $0x5
  jmp alltraps
80106911:	e9 0e f9 ff ff       	jmp    80106224 <alltraps>

80106916 <vector6>:
.globl vector6
vector6:
  pushl $0
80106916:	6a 00                	push   $0x0
  pushl $6
80106918:	6a 06                	push   $0x6
  jmp alltraps
8010691a:	e9 05 f9 ff ff       	jmp    80106224 <alltraps>

8010691f <vector7>:
.globl vector7
vector7:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $7
80106921:	6a 07                	push   $0x7
  jmp alltraps
80106923:	e9 fc f8 ff ff       	jmp    80106224 <alltraps>

80106928 <vector8>:
.globl vector8
vector8:
  pushl $8
80106928:	6a 08                	push   $0x8
  jmp alltraps
8010692a:	e9 f5 f8 ff ff       	jmp    80106224 <alltraps>

8010692f <vector9>:
.globl vector9
vector9:
  pushl $0
8010692f:	6a 00                	push   $0x0
  pushl $9
80106931:	6a 09                	push   $0x9
  jmp alltraps
80106933:	e9 ec f8 ff ff       	jmp    80106224 <alltraps>

80106938 <vector10>:
.globl vector10
vector10:
  pushl $10
80106938:	6a 0a                	push   $0xa
  jmp alltraps
8010693a:	e9 e5 f8 ff ff       	jmp    80106224 <alltraps>

8010693f <vector11>:
.globl vector11
vector11:
  pushl $11
8010693f:	6a 0b                	push   $0xb
  jmp alltraps
80106941:	e9 de f8 ff ff       	jmp    80106224 <alltraps>

80106946 <vector12>:
.globl vector12
vector12:
  pushl $12
80106946:	6a 0c                	push   $0xc
  jmp alltraps
80106948:	e9 d7 f8 ff ff       	jmp    80106224 <alltraps>

8010694d <vector13>:
.globl vector13
vector13:
  pushl $13
8010694d:	6a 0d                	push   $0xd
  jmp alltraps
8010694f:	e9 d0 f8 ff ff       	jmp    80106224 <alltraps>

80106954 <vector14>:
.globl vector14
vector14:
  pushl $14
80106954:	6a 0e                	push   $0xe
  jmp alltraps
80106956:	e9 c9 f8 ff ff       	jmp    80106224 <alltraps>

8010695b <vector15>:
.globl vector15
vector15:
  pushl $0
8010695b:	6a 00                	push   $0x0
  pushl $15
8010695d:	6a 0f                	push   $0xf
  jmp alltraps
8010695f:	e9 c0 f8 ff ff       	jmp    80106224 <alltraps>

80106964 <vector16>:
.globl vector16
vector16:
  pushl $0
80106964:	6a 00                	push   $0x0
  pushl $16
80106966:	6a 10                	push   $0x10
  jmp alltraps
80106968:	e9 b7 f8 ff ff       	jmp    80106224 <alltraps>

8010696d <vector17>:
.globl vector17
vector17:
  pushl $17
8010696d:	6a 11                	push   $0x11
  jmp alltraps
8010696f:	e9 b0 f8 ff ff       	jmp    80106224 <alltraps>

80106974 <vector18>:
.globl vector18
vector18:
  pushl $0
80106974:	6a 00                	push   $0x0
  pushl $18
80106976:	6a 12                	push   $0x12
  jmp alltraps
80106978:	e9 a7 f8 ff ff       	jmp    80106224 <alltraps>

8010697d <vector19>:
.globl vector19
vector19:
  pushl $0
8010697d:	6a 00                	push   $0x0
  pushl $19
8010697f:	6a 13                	push   $0x13
  jmp alltraps
80106981:	e9 9e f8 ff ff       	jmp    80106224 <alltraps>

80106986 <vector20>:
.globl vector20
vector20:
  pushl $0
80106986:	6a 00                	push   $0x0
  pushl $20
80106988:	6a 14                	push   $0x14
  jmp alltraps
8010698a:	e9 95 f8 ff ff       	jmp    80106224 <alltraps>

8010698f <vector21>:
.globl vector21
vector21:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $21
80106991:	6a 15                	push   $0x15
  jmp alltraps
80106993:	e9 8c f8 ff ff       	jmp    80106224 <alltraps>

80106998 <vector22>:
.globl vector22
vector22:
  pushl $0
80106998:	6a 00                	push   $0x0
  pushl $22
8010699a:	6a 16                	push   $0x16
  jmp alltraps
8010699c:	e9 83 f8 ff ff       	jmp    80106224 <alltraps>

801069a1 <vector23>:
.globl vector23
vector23:
  pushl $0
801069a1:	6a 00                	push   $0x0
  pushl $23
801069a3:	6a 17                	push   $0x17
  jmp alltraps
801069a5:	e9 7a f8 ff ff       	jmp    80106224 <alltraps>

801069aa <vector24>:
.globl vector24
vector24:
  pushl $0
801069aa:	6a 00                	push   $0x0
  pushl $24
801069ac:	6a 18                	push   $0x18
  jmp alltraps
801069ae:	e9 71 f8 ff ff       	jmp    80106224 <alltraps>

801069b3 <vector25>:
.globl vector25
vector25:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $25
801069b5:	6a 19                	push   $0x19
  jmp alltraps
801069b7:	e9 68 f8 ff ff       	jmp    80106224 <alltraps>

801069bc <vector26>:
.globl vector26
vector26:
  pushl $0
801069bc:	6a 00                	push   $0x0
  pushl $26
801069be:	6a 1a                	push   $0x1a
  jmp alltraps
801069c0:	e9 5f f8 ff ff       	jmp    80106224 <alltraps>

801069c5 <vector27>:
.globl vector27
vector27:
  pushl $0
801069c5:	6a 00                	push   $0x0
  pushl $27
801069c7:	6a 1b                	push   $0x1b
  jmp alltraps
801069c9:	e9 56 f8 ff ff       	jmp    80106224 <alltraps>

801069ce <vector28>:
.globl vector28
vector28:
  pushl $0
801069ce:	6a 00                	push   $0x0
  pushl $28
801069d0:	6a 1c                	push   $0x1c
  jmp alltraps
801069d2:	e9 4d f8 ff ff       	jmp    80106224 <alltraps>

801069d7 <vector29>:
.globl vector29
vector29:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $29
801069d9:	6a 1d                	push   $0x1d
  jmp alltraps
801069db:	e9 44 f8 ff ff       	jmp    80106224 <alltraps>

801069e0 <vector30>:
.globl vector30
vector30:
  pushl $0
801069e0:	6a 00                	push   $0x0
  pushl $30
801069e2:	6a 1e                	push   $0x1e
  jmp alltraps
801069e4:	e9 3b f8 ff ff       	jmp    80106224 <alltraps>

801069e9 <vector31>:
.globl vector31
vector31:
  pushl $0
801069e9:	6a 00                	push   $0x0
  pushl $31
801069eb:	6a 1f                	push   $0x1f
  jmp alltraps
801069ed:	e9 32 f8 ff ff       	jmp    80106224 <alltraps>

801069f2 <vector32>:
.globl vector32
vector32:
  pushl $0
801069f2:	6a 00                	push   $0x0
  pushl $32
801069f4:	6a 20                	push   $0x20
  jmp alltraps
801069f6:	e9 29 f8 ff ff       	jmp    80106224 <alltraps>

801069fb <vector33>:
.globl vector33
vector33:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $33
801069fd:	6a 21                	push   $0x21
  jmp alltraps
801069ff:	e9 20 f8 ff ff       	jmp    80106224 <alltraps>

80106a04 <vector34>:
.globl vector34
vector34:
  pushl $0
80106a04:	6a 00                	push   $0x0
  pushl $34
80106a06:	6a 22                	push   $0x22
  jmp alltraps
80106a08:	e9 17 f8 ff ff       	jmp    80106224 <alltraps>

80106a0d <vector35>:
.globl vector35
vector35:
  pushl $0
80106a0d:	6a 00                	push   $0x0
  pushl $35
80106a0f:	6a 23                	push   $0x23
  jmp alltraps
80106a11:	e9 0e f8 ff ff       	jmp    80106224 <alltraps>

80106a16 <vector36>:
.globl vector36
vector36:
  pushl $0
80106a16:	6a 00                	push   $0x0
  pushl $36
80106a18:	6a 24                	push   $0x24
  jmp alltraps
80106a1a:	e9 05 f8 ff ff       	jmp    80106224 <alltraps>

80106a1f <vector37>:
.globl vector37
vector37:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $37
80106a21:	6a 25                	push   $0x25
  jmp alltraps
80106a23:	e9 fc f7 ff ff       	jmp    80106224 <alltraps>

80106a28 <vector38>:
.globl vector38
vector38:
  pushl $0
80106a28:	6a 00                	push   $0x0
  pushl $38
80106a2a:	6a 26                	push   $0x26
  jmp alltraps
80106a2c:	e9 f3 f7 ff ff       	jmp    80106224 <alltraps>

80106a31 <vector39>:
.globl vector39
vector39:
  pushl $0
80106a31:	6a 00                	push   $0x0
  pushl $39
80106a33:	6a 27                	push   $0x27
  jmp alltraps
80106a35:	e9 ea f7 ff ff       	jmp    80106224 <alltraps>

80106a3a <vector40>:
.globl vector40
vector40:
  pushl $0
80106a3a:	6a 00                	push   $0x0
  pushl $40
80106a3c:	6a 28                	push   $0x28
  jmp alltraps
80106a3e:	e9 e1 f7 ff ff       	jmp    80106224 <alltraps>

80106a43 <vector41>:
.globl vector41
vector41:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $41
80106a45:	6a 29                	push   $0x29
  jmp alltraps
80106a47:	e9 d8 f7 ff ff       	jmp    80106224 <alltraps>

80106a4c <vector42>:
.globl vector42
vector42:
  pushl $0
80106a4c:	6a 00                	push   $0x0
  pushl $42
80106a4e:	6a 2a                	push   $0x2a
  jmp alltraps
80106a50:	e9 cf f7 ff ff       	jmp    80106224 <alltraps>

80106a55 <vector43>:
.globl vector43
vector43:
  pushl $0
80106a55:	6a 00                	push   $0x0
  pushl $43
80106a57:	6a 2b                	push   $0x2b
  jmp alltraps
80106a59:	e9 c6 f7 ff ff       	jmp    80106224 <alltraps>

80106a5e <vector44>:
.globl vector44
vector44:
  pushl $0
80106a5e:	6a 00                	push   $0x0
  pushl $44
80106a60:	6a 2c                	push   $0x2c
  jmp alltraps
80106a62:	e9 bd f7 ff ff       	jmp    80106224 <alltraps>

80106a67 <vector45>:
.globl vector45
vector45:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $45
80106a69:	6a 2d                	push   $0x2d
  jmp alltraps
80106a6b:	e9 b4 f7 ff ff       	jmp    80106224 <alltraps>

80106a70 <vector46>:
.globl vector46
vector46:
  pushl $0
80106a70:	6a 00                	push   $0x0
  pushl $46
80106a72:	6a 2e                	push   $0x2e
  jmp alltraps
80106a74:	e9 ab f7 ff ff       	jmp    80106224 <alltraps>

80106a79 <vector47>:
.globl vector47
vector47:
  pushl $0
80106a79:	6a 00                	push   $0x0
  pushl $47
80106a7b:	6a 2f                	push   $0x2f
  jmp alltraps
80106a7d:	e9 a2 f7 ff ff       	jmp    80106224 <alltraps>

80106a82 <vector48>:
.globl vector48
vector48:
  pushl $0
80106a82:	6a 00                	push   $0x0
  pushl $48
80106a84:	6a 30                	push   $0x30
  jmp alltraps
80106a86:	e9 99 f7 ff ff       	jmp    80106224 <alltraps>

80106a8b <vector49>:
.globl vector49
vector49:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $49
80106a8d:	6a 31                	push   $0x31
  jmp alltraps
80106a8f:	e9 90 f7 ff ff       	jmp    80106224 <alltraps>

80106a94 <vector50>:
.globl vector50
vector50:
  pushl $0
80106a94:	6a 00                	push   $0x0
  pushl $50
80106a96:	6a 32                	push   $0x32
  jmp alltraps
80106a98:	e9 87 f7 ff ff       	jmp    80106224 <alltraps>

80106a9d <vector51>:
.globl vector51
vector51:
  pushl $0
80106a9d:	6a 00                	push   $0x0
  pushl $51
80106a9f:	6a 33                	push   $0x33
  jmp alltraps
80106aa1:	e9 7e f7 ff ff       	jmp    80106224 <alltraps>

80106aa6 <vector52>:
.globl vector52
vector52:
  pushl $0
80106aa6:	6a 00                	push   $0x0
  pushl $52
80106aa8:	6a 34                	push   $0x34
  jmp alltraps
80106aaa:	e9 75 f7 ff ff       	jmp    80106224 <alltraps>

80106aaf <vector53>:
.globl vector53
vector53:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $53
80106ab1:	6a 35                	push   $0x35
  jmp alltraps
80106ab3:	e9 6c f7 ff ff       	jmp    80106224 <alltraps>

80106ab8 <vector54>:
.globl vector54
vector54:
  pushl $0
80106ab8:	6a 00                	push   $0x0
  pushl $54
80106aba:	6a 36                	push   $0x36
  jmp alltraps
80106abc:	e9 63 f7 ff ff       	jmp    80106224 <alltraps>

80106ac1 <vector55>:
.globl vector55
vector55:
  pushl $0
80106ac1:	6a 00                	push   $0x0
  pushl $55
80106ac3:	6a 37                	push   $0x37
  jmp alltraps
80106ac5:	e9 5a f7 ff ff       	jmp    80106224 <alltraps>

80106aca <vector56>:
.globl vector56
vector56:
  pushl $0
80106aca:	6a 00                	push   $0x0
  pushl $56
80106acc:	6a 38                	push   $0x38
  jmp alltraps
80106ace:	e9 51 f7 ff ff       	jmp    80106224 <alltraps>

80106ad3 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $57
80106ad5:	6a 39                	push   $0x39
  jmp alltraps
80106ad7:	e9 48 f7 ff ff       	jmp    80106224 <alltraps>

80106adc <vector58>:
.globl vector58
vector58:
  pushl $0
80106adc:	6a 00                	push   $0x0
  pushl $58
80106ade:	6a 3a                	push   $0x3a
  jmp alltraps
80106ae0:	e9 3f f7 ff ff       	jmp    80106224 <alltraps>

80106ae5 <vector59>:
.globl vector59
vector59:
  pushl $0
80106ae5:	6a 00                	push   $0x0
  pushl $59
80106ae7:	6a 3b                	push   $0x3b
  jmp alltraps
80106ae9:	e9 36 f7 ff ff       	jmp    80106224 <alltraps>

80106aee <vector60>:
.globl vector60
vector60:
  pushl $0
80106aee:	6a 00                	push   $0x0
  pushl $60
80106af0:	6a 3c                	push   $0x3c
  jmp alltraps
80106af2:	e9 2d f7 ff ff       	jmp    80106224 <alltraps>

80106af7 <vector61>:
.globl vector61
vector61:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $61
80106af9:	6a 3d                	push   $0x3d
  jmp alltraps
80106afb:	e9 24 f7 ff ff       	jmp    80106224 <alltraps>

80106b00 <vector62>:
.globl vector62
vector62:
  pushl $0
80106b00:	6a 00                	push   $0x0
  pushl $62
80106b02:	6a 3e                	push   $0x3e
  jmp alltraps
80106b04:	e9 1b f7 ff ff       	jmp    80106224 <alltraps>

80106b09 <vector63>:
.globl vector63
vector63:
  pushl $0
80106b09:	6a 00                	push   $0x0
  pushl $63
80106b0b:	6a 3f                	push   $0x3f
  jmp alltraps
80106b0d:	e9 12 f7 ff ff       	jmp    80106224 <alltraps>

80106b12 <vector64>:
.globl vector64
vector64:
  pushl $0
80106b12:	6a 00                	push   $0x0
  pushl $64
80106b14:	6a 40                	push   $0x40
  jmp alltraps
80106b16:	e9 09 f7 ff ff       	jmp    80106224 <alltraps>

80106b1b <vector65>:
.globl vector65
vector65:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $65
80106b1d:	6a 41                	push   $0x41
  jmp alltraps
80106b1f:	e9 00 f7 ff ff       	jmp    80106224 <alltraps>

80106b24 <vector66>:
.globl vector66
vector66:
  pushl $0
80106b24:	6a 00                	push   $0x0
  pushl $66
80106b26:	6a 42                	push   $0x42
  jmp alltraps
80106b28:	e9 f7 f6 ff ff       	jmp    80106224 <alltraps>

80106b2d <vector67>:
.globl vector67
vector67:
  pushl $0
80106b2d:	6a 00                	push   $0x0
  pushl $67
80106b2f:	6a 43                	push   $0x43
  jmp alltraps
80106b31:	e9 ee f6 ff ff       	jmp    80106224 <alltraps>

80106b36 <vector68>:
.globl vector68
vector68:
  pushl $0
80106b36:	6a 00                	push   $0x0
  pushl $68
80106b38:	6a 44                	push   $0x44
  jmp alltraps
80106b3a:	e9 e5 f6 ff ff       	jmp    80106224 <alltraps>

80106b3f <vector69>:
.globl vector69
vector69:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $69
80106b41:	6a 45                	push   $0x45
  jmp alltraps
80106b43:	e9 dc f6 ff ff       	jmp    80106224 <alltraps>

80106b48 <vector70>:
.globl vector70
vector70:
  pushl $0
80106b48:	6a 00                	push   $0x0
  pushl $70
80106b4a:	6a 46                	push   $0x46
  jmp alltraps
80106b4c:	e9 d3 f6 ff ff       	jmp    80106224 <alltraps>

80106b51 <vector71>:
.globl vector71
vector71:
  pushl $0
80106b51:	6a 00                	push   $0x0
  pushl $71
80106b53:	6a 47                	push   $0x47
  jmp alltraps
80106b55:	e9 ca f6 ff ff       	jmp    80106224 <alltraps>

80106b5a <vector72>:
.globl vector72
vector72:
  pushl $0
80106b5a:	6a 00                	push   $0x0
  pushl $72
80106b5c:	6a 48                	push   $0x48
  jmp alltraps
80106b5e:	e9 c1 f6 ff ff       	jmp    80106224 <alltraps>

80106b63 <vector73>:
.globl vector73
vector73:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $73
80106b65:	6a 49                	push   $0x49
  jmp alltraps
80106b67:	e9 b8 f6 ff ff       	jmp    80106224 <alltraps>

80106b6c <vector74>:
.globl vector74
vector74:
  pushl $0
80106b6c:	6a 00                	push   $0x0
  pushl $74
80106b6e:	6a 4a                	push   $0x4a
  jmp alltraps
80106b70:	e9 af f6 ff ff       	jmp    80106224 <alltraps>

80106b75 <vector75>:
.globl vector75
vector75:
  pushl $0
80106b75:	6a 00                	push   $0x0
  pushl $75
80106b77:	6a 4b                	push   $0x4b
  jmp alltraps
80106b79:	e9 a6 f6 ff ff       	jmp    80106224 <alltraps>

80106b7e <vector76>:
.globl vector76
vector76:
  pushl $0
80106b7e:	6a 00                	push   $0x0
  pushl $76
80106b80:	6a 4c                	push   $0x4c
  jmp alltraps
80106b82:	e9 9d f6 ff ff       	jmp    80106224 <alltraps>

80106b87 <vector77>:
.globl vector77
vector77:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $77
80106b89:	6a 4d                	push   $0x4d
  jmp alltraps
80106b8b:	e9 94 f6 ff ff       	jmp    80106224 <alltraps>

80106b90 <vector78>:
.globl vector78
vector78:
  pushl $0
80106b90:	6a 00                	push   $0x0
  pushl $78
80106b92:	6a 4e                	push   $0x4e
  jmp alltraps
80106b94:	e9 8b f6 ff ff       	jmp    80106224 <alltraps>

80106b99 <vector79>:
.globl vector79
vector79:
  pushl $0
80106b99:	6a 00                	push   $0x0
  pushl $79
80106b9b:	6a 4f                	push   $0x4f
  jmp alltraps
80106b9d:	e9 82 f6 ff ff       	jmp    80106224 <alltraps>

80106ba2 <vector80>:
.globl vector80
vector80:
  pushl $0
80106ba2:	6a 00                	push   $0x0
  pushl $80
80106ba4:	6a 50                	push   $0x50
  jmp alltraps
80106ba6:	e9 79 f6 ff ff       	jmp    80106224 <alltraps>

80106bab <vector81>:
.globl vector81
vector81:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $81
80106bad:	6a 51                	push   $0x51
  jmp alltraps
80106baf:	e9 70 f6 ff ff       	jmp    80106224 <alltraps>

80106bb4 <vector82>:
.globl vector82
vector82:
  pushl $0
80106bb4:	6a 00                	push   $0x0
  pushl $82
80106bb6:	6a 52                	push   $0x52
  jmp alltraps
80106bb8:	e9 67 f6 ff ff       	jmp    80106224 <alltraps>

80106bbd <vector83>:
.globl vector83
vector83:
  pushl $0
80106bbd:	6a 00                	push   $0x0
  pushl $83
80106bbf:	6a 53                	push   $0x53
  jmp alltraps
80106bc1:	e9 5e f6 ff ff       	jmp    80106224 <alltraps>

80106bc6 <vector84>:
.globl vector84
vector84:
  pushl $0
80106bc6:	6a 00                	push   $0x0
  pushl $84
80106bc8:	6a 54                	push   $0x54
  jmp alltraps
80106bca:	e9 55 f6 ff ff       	jmp    80106224 <alltraps>

80106bcf <vector85>:
.globl vector85
vector85:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $85
80106bd1:	6a 55                	push   $0x55
  jmp alltraps
80106bd3:	e9 4c f6 ff ff       	jmp    80106224 <alltraps>

80106bd8 <vector86>:
.globl vector86
vector86:
  pushl $0
80106bd8:	6a 00                	push   $0x0
  pushl $86
80106bda:	6a 56                	push   $0x56
  jmp alltraps
80106bdc:	e9 43 f6 ff ff       	jmp    80106224 <alltraps>

80106be1 <vector87>:
.globl vector87
vector87:
  pushl $0
80106be1:	6a 00                	push   $0x0
  pushl $87
80106be3:	6a 57                	push   $0x57
  jmp alltraps
80106be5:	e9 3a f6 ff ff       	jmp    80106224 <alltraps>

80106bea <vector88>:
.globl vector88
vector88:
  pushl $0
80106bea:	6a 00                	push   $0x0
  pushl $88
80106bec:	6a 58                	push   $0x58
  jmp alltraps
80106bee:	e9 31 f6 ff ff       	jmp    80106224 <alltraps>

80106bf3 <vector89>:
.globl vector89
vector89:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $89
80106bf5:	6a 59                	push   $0x59
  jmp alltraps
80106bf7:	e9 28 f6 ff ff       	jmp    80106224 <alltraps>

80106bfc <vector90>:
.globl vector90
vector90:
  pushl $0
80106bfc:	6a 00                	push   $0x0
  pushl $90
80106bfe:	6a 5a                	push   $0x5a
  jmp alltraps
80106c00:	e9 1f f6 ff ff       	jmp    80106224 <alltraps>

80106c05 <vector91>:
.globl vector91
vector91:
  pushl $0
80106c05:	6a 00                	push   $0x0
  pushl $91
80106c07:	6a 5b                	push   $0x5b
  jmp alltraps
80106c09:	e9 16 f6 ff ff       	jmp    80106224 <alltraps>

80106c0e <vector92>:
.globl vector92
vector92:
  pushl $0
80106c0e:	6a 00                	push   $0x0
  pushl $92
80106c10:	6a 5c                	push   $0x5c
  jmp alltraps
80106c12:	e9 0d f6 ff ff       	jmp    80106224 <alltraps>

80106c17 <vector93>:
.globl vector93
vector93:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $93
80106c19:	6a 5d                	push   $0x5d
  jmp alltraps
80106c1b:	e9 04 f6 ff ff       	jmp    80106224 <alltraps>

80106c20 <vector94>:
.globl vector94
vector94:
  pushl $0
80106c20:	6a 00                	push   $0x0
  pushl $94
80106c22:	6a 5e                	push   $0x5e
  jmp alltraps
80106c24:	e9 fb f5 ff ff       	jmp    80106224 <alltraps>

80106c29 <vector95>:
.globl vector95
vector95:
  pushl $0
80106c29:	6a 00                	push   $0x0
  pushl $95
80106c2b:	6a 5f                	push   $0x5f
  jmp alltraps
80106c2d:	e9 f2 f5 ff ff       	jmp    80106224 <alltraps>

80106c32 <vector96>:
.globl vector96
vector96:
  pushl $0
80106c32:	6a 00                	push   $0x0
  pushl $96
80106c34:	6a 60                	push   $0x60
  jmp alltraps
80106c36:	e9 e9 f5 ff ff       	jmp    80106224 <alltraps>

80106c3b <vector97>:
.globl vector97
vector97:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $97
80106c3d:	6a 61                	push   $0x61
  jmp alltraps
80106c3f:	e9 e0 f5 ff ff       	jmp    80106224 <alltraps>

80106c44 <vector98>:
.globl vector98
vector98:
  pushl $0
80106c44:	6a 00                	push   $0x0
  pushl $98
80106c46:	6a 62                	push   $0x62
  jmp alltraps
80106c48:	e9 d7 f5 ff ff       	jmp    80106224 <alltraps>

80106c4d <vector99>:
.globl vector99
vector99:
  pushl $0
80106c4d:	6a 00                	push   $0x0
  pushl $99
80106c4f:	6a 63                	push   $0x63
  jmp alltraps
80106c51:	e9 ce f5 ff ff       	jmp    80106224 <alltraps>

80106c56 <vector100>:
.globl vector100
vector100:
  pushl $0
80106c56:	6a 00                	push   $0x0
  pushl $100
80106c58:	6a 64                	push   $0x64
  jmp alltraps
80106c5a:	e9 c5 f5 ff ff       	jmp    80106224 <alltraps>

80106c5f <vector101>:
.globl vector101
vector101:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $101
80106c61:	6a 65                	push   $0x65
  jmp alltraps
80106c63:	e9 bc f5 ff ff       	jmp    80106224 <alltraps>

80106c68 <vector102>:
.globl vector102
vector102:
  pushl $0
80106c68:	6a 00                	push   $0x0
  pushl $102
80106c6a:	6a 66                	push   $0x66
  jmp alltraps
80106c6c:	e9 b3 f5 ff ff       	jmp    80106224 <alltraps>

80106c71 <vector103>:
.globl vector103
vector103:
  pushl $0
80106c71:	6a 00                	push   $0x0
  pushl $103
80106c73:	6a 67                	push   $0x67
  jmp alltraps
80106c75:	e9 aa f5 ff ff       	jmp    80106224 <alltraps>

80106c7a <vector104>:
.globl vector104
vector104:
  pushl $0
80106c7a:	6a 00                	push   $0x0
  pushl $104
80106c7c:	6a 68                	push   $0x68
  jmp alltraps
80106c7e:	e9 a1 f5 ff ff       	jmp    80106224 <alltraps>

80106c83 <vector105>:
.globl vector105
vector105:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $105
80106c85:	6a 69                	push   $0x69
  jmp alltraps
80106c87:	e9 98 f5 ff ff       	jmp    80106224 <alltraps>

80106c8c <vector106>:
.globl vector106
vector106:
  pushl $0
80106c8c:	6a 00                	push   $0x0
  pushl $106
80106c8e:	6a 6a                	push   $0x6a
  jmp alltraps
80106c90:	e9 8f f5 ff ff       	jmp    80106224 <alltraps>

80106c95 <vector107>:
.globl vector107
vector107:
  pushl $0
80106c95:	6a 00                	push   $0x0
  pushl $107
80106c97:	6a 6b                	push   $0x6b
  jmp alltraps
80106c99:	e9 86 f5 ff ff       	jmp    80106224 <alltraps>

80106c9e <vector108>:
.globl vector108
vector108:
  pushl $0
80106c9e:	6a 00                	push   $0x0
  pushl $108
80106ca0:	6a 6c                	push   $0x6c
  jmp alltraps
80106ca2:	e9 7d f5 ff ff       	jmp    80106224 <alltraps>

80106ca7 <vector109>:
.globl vector109
vector109:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $109
80106ca9:	6a 6d                	push   $0x6d
  jmp alltraps
80106cab:	e9 74 f5 ff ff       	jmp    80106224 <alltraps>

80106cb0 <vector110>:
.globl vector110
vector110:
  pushl $0
80106cb0:	6a 00                	push   $0x0
  pushl $110
80106cb2:	6a 6e                	push   $0x6e
  jmp alltraps
80106cb4:	e9 6b f5 ff ff       	jmp    80106224 <alltraps>

80106cb9 <vector111>:
.globl vector111
vector111:
  pushl $0
80106cb9:	6a 00                	push   $0x0
  pushl $111
80106cbb:	6a 6f                	push   $0x6f
  jmp alltraps
80106cbd:	e9 62 f5 ff ff       	jmp    80106224 <alltraps>

80106cc2 <vector112>:
.globl vector112
vector112:
  pushl $0
80106cc2:	6a 00                	push   $0x0
  pushl $112
80106cc4:	6a 70                	push   $0x70
  jmp alltraps
80106cc6:	e9 59 f5 ff ff       	jmp    80106224 <alltraps>

80106ccb <vector113>:
.globl vector113
vector113:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $113
80106ccd:	6a 71                	push   $0x71
  jmp alltraps
80106ccf:	e9 50 f5 ff ff       	jmp    80106224 <alltraps>

80106cd4 <vector114>:
.globl vector114
vector114:
  pushl $0
80106cd4:	6a 00                	push   $0x0
  pushl $114
80106cd6:	6a 72                	push   $0x72
  jmp alltraps
80106cd8:	e9 47 f5 ff ff       	jmp    80106224 <alltraps>

80106cdd <vector115>:
.globl vector115
vector115:
  pushl $0
80106cdd:	6a 00                	push   $0x0
  pushl $115
80106cdf:	6a 73                	push   $0x73
  jmp alltraps
80106ce1:	e9 3e f5 ff ff       	jmp    80106224 <alltraps>

80106ce6 <vector116>:
.globl vector116
vector116:
  pushl $0
80106ce6:	6a 00                	push   $0x0
  pushl $116
80106ce8:	6a 74                	push   $0x74
  jmp alltraps
80106cea:	e9 35 f5 ff ff       	jmp    80106224 <alltraps>

80106cef <vector117>:
.globl vector117
vector117:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $117
80106cf1:	6a 75                	push   $0x75
  jmp alltraps
80106cf3:	e9 2c f5 ff ff       	jmp    80106224 <alltraps>

80106cf8 <vector118>:
.globl vector118
vector118:
  pushl $0
80106cf8:	6a 00                	push   $0x0
  pushl $118
80106cfa:	6a 76                	push   $0x76
  jmp alltraps
80106cfc:	e9 23 f5 ff ff       	jmp    80106224 <alltraps>

80106d01 <vector119>:
.globl vector119
vector119:
  pushl $0
80106d01:	6a 00                	push   $0x0
  pushl $119
80106d03:	6a 77                	push   $0x77
  jmp alltraps
80106d05:	e9 1a f5 ff ff       	jmp    80106224 <alltraps>

80106d0a <vector120>:
.globl vector120
vector120:
  pushl $0
80106d0a:	6a 00                	push   $0x0
  pushl $120
80106d0c:	6a 78                	push   $0x78
  jmp alltraps
80106d0e:	e9 11 f5 ff ff       	jmp    80106224 <alltraps>

80106d13 <vector121>:
.globl vector121
vector121:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $121
80106d15:	6a 79                	push   $0x79
  jmp alltraps
80106d17:	e9 08 f5 ff ff       	jmp    80106224 <alltraps>

80106d1c <vector122>:
.globl vector122
vector122:
  pushl $0
80106d1c:	6a 00                	push   $0x0
  pushl $122
80106d1e:	6a 7a                	push   $0x7a
  jmp alltraps
80106d20:	e9 ff f4 ff ff       	jmp    80106224 <alltraps>

80106d25 <vector123>:
.globl vector123
vector123:
  pushl $0
80106d25:	6a 00                	push   $0x0
  pushl $123
80106d27:	6a 7b                	push   $0x7b
  jmp alltraps
80106d29:	e9 f6 f4 ff ff       	jmp    80106224 <alltraps>

80106d2e <vector124>:
.globl vector124
vector124:
  pushl $0
80106d2e:	6a 00                	push   $0x0
  pushl $124
80106d30:	6a 7c                	push   $0x7c
  jmp alltraps
80106d32:	e9 ed f4 ff ff       	jmp    80106224 <alltraps>

80106d37 <vector125>:
.globl vector125
vector125:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $125
80106d39:	6a 7d                	push   $0x7d
  jmp alltraps
80106d3b:	e9 e4 f4 ff ff       	jmp    80106224 <alltraps>

80106d40 <vector126>:
.globl vector126
vector126:
  pushl $0
80106d40:	6a 00                	push   $0x0
  pushl $126
80106d42:	6a 7e                	push   $0x7e
  jmp alltraps
80106d44:	e9 db f4 ff ff       	jmp    80106224 <alltraps>

80106d49 <vector127>:
.globl vector127
vector127:
  pushl $0
80106d49:	6a 00                	push   $0x0
  pushl $127
80106d4b:	6a 7f                	push   $0x7f
  jmp alltraps
80106d4d:	e9 d2 f4 ff ff       	jmp    80106224 <alltraps>

80106d52 <vector128>:
.globl vector128
vector128:
  pushl $0
80106d52:	6a 00                	push   $0x0
  pushl $128
80106d54:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106d59:	e9 c6 f4 ff ff       	jmp    80106224 <alltraps>

80106d5e <vector129>:
.globl vector129
vector129:
  pushl $0
80106d5e:	6a 00                	push   $0x0
  pushl $129
80106d60:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106d65:	e9 ba f4 ff ff       	jmp    80106224 <alltraps>

80106d6a <vector130>:
.globl vector130
vector130:
  pushl $0
80106d6a:	6a 00                	push   $0x0
  pushl $130
80106d6c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106d71:	e9 ae f4 ff ff       	jmp    80106224 <alltraps>

80106d76 <vector131>:
.globl vector131
vector131:
  pushl $0
80106d76:	6a 00                	push   $0x0
  pushl $131
80106d78:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106d7d:	e9 a2 f4 ff ff       	jmp    80106224 <alltraps>

80106d82 <vector132>:
.globl vector132
vector132:
  pushl $0
80106d82:	6a 00                	push   $0x0
  pushl $132
80106d84:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106d89:	e9 96 f4 ff ff       	jmp    80106224 <alltraps>

80106d8e <vector133>:
.globl vector133
vector133:
  pushl $0
80106d8e:	6a 00                	push   $0x0
  pushl $133
80106d90:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106d95:	e9 8a f4 ff ff       	jmp    80106224 <alltraps>

80106d9a <vector134>:
.globl vector134
vector134:
  pushl $0
80106d9a:	6a 00                	push   $0x0
  pushl $134
80106d9c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106da1:	e9 7e f4 ff ff       	jmp    80106224 <alltraps>

80106da6 <vector135>:
.globl vector135
vector135:
  pushl $0
80106da6:	6a 00                	push   $0x0
  pushl $135
80106da8:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106dad:	e9 72 f4 ff ff       	jmp    80106224 <alltraps>

80106db2 <vector136>:
.globl vector136
vector136:
  pushl $0
80106db2:	6a 00                	push   $0x0
  pushl $136
80106db4:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106db9:	e9 66 f4 ff ff       	jmp    80106224 <alltraps>

80106dbe <vector137>:
.globl vector137
vector137:
  pushl $0
80106dbe:	6a 00                	push   $0x0
  pushl $137
80106dc0:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106dc5:	e9 5a f4 ff ff       	jmp    80106224 <alltraps>

80106dca <vector138>:
.globl vector138
vector138:
  pushl $0
80106dca:	6a 00                	push   $0x0
  pushl $138
80106dcc:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106dd1:	e9 4e f4 ff ff       	jmp    80106224 <alltraps>

80106dd6 <vector139>:
.globl vector139
vector139:
  pushl $0
80106dd6:	6a 00                	push   $0x0
  pushl $139
80106dd8:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ddd:	e9 42 f4 ff ff       	jmp    80106224 <alltraps>

80106de2 <vector140>:
.globl vector140
vector140:
  pushl $0
80106de2:	6a 00                	push   $0x0
  pushl $140
80106de4:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106de9:	e9 36 f4 ff ff       	jmp    80106224 <alltraps>

80106dee <vector141>:
.globl vector141
vector141:
  pushl $0
80106dee:	6a 00                	push   $0x0
  pushl $141
80106df0:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106df5:	e9 2a f4 ff ff       	jmp    80106224 <alltraps>

80106dfa <vector142>:
.globl vector142
vector142:
  pushl $0
80106dfa:	6a 00                	push   $0x0
  pushl $142
80106dfc:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106e01:	e9 1e f4 ff ff       	jmp    80106224 <alltraps>

80106e06 <vector143>:
.globl vector143
vector143:
  pushl $0
80106e06:	6a 00                	push   $0x0
  pushl $143
80106e08:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106e0d:	e9 12 f4 ff ff       	jmp    80106224 <alltraps>

80106e12 <vector144>:
.globl vector144
vector144:
  pushl $0
80106e12:	6a 00                	push   $0x0
  pushl $144
80106e14:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106e19:	e9 06 f4 ff ff       	jmp    80106224 <alltraps>

80106e1e <vector145>:
.globl vector145
vector145:
  pushl $0
80106e1e:	6a 00                	push   $0x0
  pushl $145
80106e20:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106e25:	e9 fa f3 ff ff       	jmp    80106224 <alltraps>

80106e2a <vector146>:
.globl vector146
vector146:
  pushl $0
80106e2a:	6a 00                	push   $0x0
  pushl $146
80106e2c:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106e31:	e9 ee f3 ff ff       	jmp    80106224 <alltraps>

80106e36 <vector147>:
.globl vector147
vector147:
  pushl $0
80106e36:	6a 00                	push   $0x0
  pushl $147
80106e38:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106e3d:	e9 e2 f3 ff ff       	jmp    80106224 <alltraps>

80106e42 <vector148>:
.globl vector148
vector148:
  pushl $0
80106e42:	6a 00                	push   $0x0
  pushl $148
80106e44:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106e49:	e9 d6 f3 ff ff       	jmp    80106224 <alltraps>

80106e4e <vector149>:
.globl vector149
vector149:
  pushl $0
80106e4e:	6a 00                	push   $0x0
  pushl $149
80106e50:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106e55:	e9 ca f3 ff ff       	jmp    80106224 <alltraps>

80106e5a <vector150>:
.globl vector150
vector150:
  pushl $0
80106e5a:	6a 00                	push   $0x0
  pushl $150
80106e5c:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106e61:	e9 be f3 ff ff       	jmp    80106224 <alltraps>

80106e66 <vector151>:
.globl vector151
vector151:
  pushl $0
80106e66:	6a 00                	push   $0x0
  pushl $151
80106e68:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106e6d:	e9 b2 f3 ff ff       	jmp    80106224 <alltraps>

80106e72 <vector152>:
.globl vector152
vector152:
  pushl $0
80106e72:	6a 00                	push   $0x0
  pushl $152
80106e74:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106e79:	e9 a6 f3 ff ff       	jmp    80106224 <alltraps>

80106e7e <vector153>:
.globl vector153
vector153:
  pushl $0
80106e7e:	6a 00                	push   $0x0
  pushl $153
80106e80:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106e85:	e9 9a f3 ff ff       	jmp    80106224 <alltraps>

80106e8a <vector154>:
.globl vector154
vector154:
  pushl $0
80106e8a:	6a 00                	push   $0x0
  pushl $154
80106e8c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106e91:	e9 8e f3 ff ff       	jmp    80106224 <alltraps>

80106e96 <vector155>:
.globl vector155
vector155:
  pushl $0
80106e96:	6a 00                	push   $0x0
  pushl $155
80106e98:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106e9d:	e9 82 f3 ff ff       	jmp    80106224 <alltraps>

80106ea2 <vector156>:
.globl vector156
vector156:
  pushl $0
80106ea2:	6a 00                	push   $0x0
  pushl $156
80106ea4:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106ea9:	e9 76 f3 ff ff       	jmp    80106224 <alltraps>

80106eae <vector157>:
.globl vector157
vector157:
  pushl $0
80106eae:	6a 00                	push   $0x0
  pushl $157
80106eb0:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106eb5:	e9 6a f3 ff ff       	jmp    80106224 <alltraps>

80106eba <vector158>:
.globl vector158
vector158:
  pushl $0
80106eba:	6a 00                	push   $0x0
  pushl $158
80106ebc:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106ec1:	e9 5e f3 ff ff       	jmp    80106224 <alltraps>

80106ec6 <vector159>:
.globl vector159
vector159:
  pushl $0
80106ec6:	6a 00                	push   $0x0
  pushl $159
80106ec8:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ecd:	e9 52 f3 ff ff       	jmp    80106224 <alltraps>

80106ed2 <vector160>:
.globl vector160
vector160:
  pushl $0
80106ed2:	6a 00                	push   $0x0
  pushl $160
80106ed4:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ed9:	e9 46 f3 ff ff       	jmp    80106224 <alltraps>

80106ede <vector161>:
.globl vector161
vector161:
  pushl $0
80106ede:	6a 00                	push   $0x0
  pushl $161
80106ee0:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106ee5:	e9 3a f3 ff ff       	jmp    80106224 <alltraps>

80106eea <vector162>:
.globl vector162
vector162:
  pushl $0
80106eea:	6a 00                	push   $0x0
  pushl $162
80106eec:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106ef1:	e9 2e f3 ff ff       	jmp    80106224 <alltraps>

80106ef6 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ef6:	6a 00                	push   $0x0
  pushl $163
80106ef8:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106efd:	e9 22 f3 ff ff       	jmp    80106224 <alltraps>

80106f02 <vector164>:
.globl vector164
vector164:
  pushl $0
80106f02:	6a 00                	push   $0x0
  pushl $164
80106f04:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106f09:	e9 16 f3 ff ff       	jmp    80106224 <alltraps>

80106f0e <vector165>:
.globl vector165
vector165:
  pushl $0
80106f0e:	6a 00                	push   $0x0
  pushl $165
80106f10:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106f15:	e9 0a f3 ff ff       	jmp    80106224 <alltraps>

80106f1a <vector166>:
.globl vector166
vector166:
  pushl $0
80106f1a:	6a 00                	push   $0x0
  pushl $166
80106f1c:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106f21:	e9 fe f2 ff ff       	jmp    80106224 <alltraps>

80106f26 <vector167>:
.globl vector167
vector167:
  pushl $0
80106f26:	6a 00                	push   $0x0
  pushl $167
80106f28:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106f2d:	e9 f2 f2 ff ff       	jmp    80106224 <alltraps>

80106f32 <vector168>:
.globl vector168
vector168:
  pushl $0
80106f32:	6a 00                	push   $0x0
  pushl $168
80106f34:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106f39:	e9 e6 f2 ff ff       	jmp    80106224 <alltraps>

80106f3e <vector169>:
.globl vector169
vector169:
  pushl $0
80106f3e:	6a 00                	push   $0x0
  pushl $169
80106f40:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106f45:	e9 da f2 ff ff       	jmp    80106224 <alltraps>

80106f4a <vector170>:
.globl vector170
vector170:
  pushl $0
80106f4a:	6a 00                	push   $0x0
  pushl $170
80106f4c:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106f51:	e9 ce f2 ff ff       	jmp    80106224 <alltraps>

80106f56 <vector171>:
.globl vector171
vector171:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $171
80106f58:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106f5d:	e9 c2 f2 ff ff       	jmp    80106224 <alltraps>

80106f62 <vector172>:
.globl vector172
vector172:
  pushl $0
80106f62:	6a 00                	push   $0x0
  pushl $172
80106f64:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106f69:	e9 b6 f2 ff ff       	jmp    80106224 <alltraps>

80106f6e <vector173>:
.globl vector173
vector173:
  pushl $0
80106f6e:	6a 00                	push   $0x0
  pushl $173
80106f70:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106f75:	e9 aa f2 ff ff       	jmp    80106224 <alltraps>

80106f7a <vector174>:
.globl vector174
vector174:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $174
80106f7c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106f81:	e9 9e f2 ff ff       	jmp    80106224 <alltraps>

80106f86 <vector175>:
.globl vector175
vector175:
  pushl $0
80106f86:	6a 00                	push   $0x0
  pushl $175
80106f88:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106f8d:	e9 92 f2 ff ff       	jmp    80106224 <alltraps>

80106f92 <vector176>:
.globl vector176
vector176:
  pushl $0
80106f92:	6a 00                	push   $0x0
  pushl $176
80106f94:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106f99:	e9 86 f2 ff ff       	jmp    80106224 <alltraps>

80106f9e <vector177>:
.globl vector177
vector177:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $177
80106fa0:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106fa5:	e9 7a f2 ff ff       	jmp    80106224 <alltraps>

80106faa <vector178>:
.globl vector178
vector178:
  pushl $0
80106faa:	6a 00                	push   $0x0
  pushl $178
80106fac:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106fb1:	e9 6e f2 ff ff       	jmp    80106224 <alltraps>

80106fb6 <vector179>:
.globl vector179
vector179:
  pushl $0
80106fb6:	6a 00                	push   $0x0
  pushl $179
80106fb8:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106fbd:	e9 62 f2 ff ff       	jmp    80106224 <alltraps>

80106fc2 <vector180>:
.globl vector180
vector180:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $180
80106fc4:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106fc9:	e9 56 f2 ff ff       	jmp    80106224 <alltraps>

80106fce <vector181>:
.globl vector181
vector181:
  pushl $0
80106fce:	6a 00                	push   $0x0
  pushl $181
80106fd0:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106fd5:	e9 4a f2 ff ff       	jmp    80106224 <alltraps>

80106fda <vector182>:
.globl vector182
vector182:
  pushl $0
80106fda:	6a 00                	push   $0x0
  pushl $182
80106fdc:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106fe1:	e9 3e f2 ff ff       	jmp    80106224 <alltraps>

80106fe6 <vector183>:
.globl vector183
vector183:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $183
80106fe8:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106fed:	e9 32 f2 ff ff       	jmp    80106224 <alltraps>

80106ff2 <vector184>:
.globl vector184
vector184:
  pushl $0
80106ff2:	6a 00                	push   $0x0
  pushl $184
80106ff4:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ff9:	e9 26 f2 ff ff       	jmp    80106224 <alltraps>

80106ffe <vector185>:
.globl vector185
vector185:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $185
80107000:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107005:	e9 1a f2 ff ff       	jmp    80106224 <alltraps>

8010700a <vector186>:
.globl vector186
vector186:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $186
8010700c:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107011:	e9 0e f2 ff ff       	jmp    80106224 <alltraps>

80107016 <vector187>:
.globl vector187
vector187:
  pushl $0
80107016:	6a 00                	push   $0x0
  pushl $187
80107018:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010701d:	e9 02 f2 ff ff       	jmp    80106224 <alltraps>

80107022 <vector188>:
.globl vector188
vector188:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $188
80107024:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107029:	e9 f6 f1 ff ff       	jmp    80106224 <alltraps>

8010702e <vector189>:
.globl vector189
vector189:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $189
80107030:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107035:	e9 ea f1 ff ff       	jmp    80106224 <alltraps>

8010703a <vector190>:
.globl vector190
vector190:
  pushl $0
8010703a:	6a 00                	push   $0x0
  pushl $190
8010703c:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107041:	e9 de f1 ff ff       	jmp    80106224 <alltraps>

80107046 <vector191>:
.globl vector191
vector191:
  pushl $0
80107046:	6a 00                	push   $0x0
  pushl $191
80107048:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010704d:	e9 d2 f1 ff ff       	jmp    80106224 <alltraps>

80107052 <vector192>:
.globl vector192
vector192:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $192
80107054:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107059:	e9 c6 f1 ff ff       	jmp    80106224 <alltraps>

8010705e <vector193>:
.globl vector193
vector193:
  pushl $0
8010705e:	6a 00                	push   $0x0
  pushl $193
80107060:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107065:	e9 ba f1 ff ff       	jmp    80106224 <alltraps>

8010706a <vector194>:
.globl vector194
vector194:
  pushl $0
8010706a:	6a 00                	push   $0x0
  pushl $194
8010706c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107071:	e9 ae f1 ff ff       	jmp    80106224 <alltraps>

80107076 <vector195>:
.globl vector195
vector195:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $195
80107078:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010707d:	e9 a2 f1 ff ff       	jmp    80106224 <alltraps>

80107082 <vector196>:
.globl vector196
vector196:
  pushl $0
80107082:	6a 00                	push   $0x0
  pushl $196
80107084:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107089:	e9 96 f1 ff ff       	jmp    80106224 <alltraps>

8010708e <vector197>:
.globl vector197
vector197:
  pushl $0
8010708e:	6a 00                	push   $0x0
  pushl $197
80107090:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107095:	e9 8a f1 ff ff       	jmp    80106224 <alltraps>

8010709a <vector198>:
.globl vector198
vector198:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $198
8010709c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801070a1:	e9 7e f1 ff ff       	jmp    80106224 <alltraps>

801070a6 <vector199>:
.globl vector199
vector199:
  pushl $0
801070a6:	6a 00                	push   $0x0
  pushl $199
801070a8:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801070ad:	e9 72 f1 ff ff       	jmp    80106224 <alltraps>

801070b2 <vector200>:
.globl vector200
vector200:
  pushl $0
801070b2:	6a 00                	push   $0x0
  pushl $200
801070b4:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801070b9:	e9 66 f1 ff ff       	jmp    80106224 <alltraps>

801070be <vector201>:
.globl vector201
vector201:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $201
801070c0:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801070c5:	e9 5a f1 ff ff       	jmp    80106224 <alltraps>

801070ca <vector202>:
.globl vector202
vector202:
  pushl $0
801070ca:	6a 00                	push   $0x0
  pushl $202
801070cc:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801070d1:	e9 4e f1 ff ff       	jmp    80106224 <alltraps>

801070d6 <vector203>:
.globl vector203
vector203:
  pushl $0
801070d6:	6a 00                	push   $0x0
  pushl $203
801070d8:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801070dd:	e9 42 f1 ff ff       	jmp    80106224 <alltraps>

801070e2 <vector204>:
.globl vector204
vector204:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $204
801070e4:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801070e9:	e9 36 f1 ff ff       	jmp    80106224 <alltraps>

801070ee <vector205>:
.globl vector205
vector205:
  pushl $0
801070ee:	6a 00                	push   $0x0
  pushl $205
801070f0:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801070f5:	e9 2a f1 ff ff       	jmp    80106224 <alltraps>

801070fa <vector206>:
.globl vector206
vector206:
  pushl $0
801070fa:	6a 00                	push   $0x0
  pushl $206
801070fc:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107101:	e9 1e f1 ff ff       	jmp    80106224 <alltraps>

80107106 <vector207>:
.globl vector207
vector207:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $207
80107108:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010710d:	e9 12 f1 ff ff       	jmp    80106224 <alltraps>

80107112 <vector208>:
.globl vector208
vector208:
  pushl $0
80107112:	6a 00                	push   $0x0
  pushl $208
80107114:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107119:	e9 06 f1 ff ff       	jmp    80106224 <alltraps>

8010711e <vector209>:
.globl vector209
vector209:
  pushl $0
8010711e:	6a 00                	push   $0x0
  pushl $209
80107120:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107125:	e9 fa f0 ff ff       	jmp    80106224 <alltraps>

8010712a <vector210>:
.globl vector210
vector210:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $210
8010712c:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107131:	e9 ee f0 ff ff       	jmp    80106224 <alltraps>

80107136 <vector211>:
.globl vector211
vector211:
  pushl $0
80107136:	6a 00                	push   $0x0
  pushl $211
80107138:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010713d:	e9 e2 f0 ff ff       	jmp    80106224 <alltraps>

80107142 <vector212>:
.globl vector212
vector212:
  pushl $0
80107142:	6a 00                	push   $0x0
  pushl $212
80107144:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107149:	e9 d6 f0 ff ff       	jmp    80106224 <alltraps>

8010714e <vector213>:
.globl vector213
vector213:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $213
80107150:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107155:	e9 ca f0 ff ff       	jmp    80106224 <alltraps>

8010715a <vector214>:
.globl vector214
vector214:
  pushl $0
8010715a:	6a 00                	push   $0x0
  pushl $214
8010715c:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107161:	e9 be f0 ff ff       	jmp    80106224 <alltraps>

80107166 <vector215>:
.globl vector215
vector215:
  pushl $0
80107166:	6a 00                	push   $0x0
  pushl $215
80107168:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010716d:	e9 b2 f0 ff ff       	jmp    80106224 <alltraps>

80107172 <vector216>:
.globl vector216
vector216:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $216
80107174:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107179:	e9 a6 f0 ff ff       	jmp    80106224 <alltraps>

8010717e <vector217>:
.globl vector217
vector217:
  pushl $0
8010717e:	6a 00                	push   $0x0
  pushl $217
80107180:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107185:	e9 9a f0 ff ff       	jmp    80106224 <alltraps>

8010718a <vector218>:
.globl vector218
vector218:
  pushl $0
8010718a:	6a 00                	push   $0x0
  pushl $218
8010718c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107191:	e9 8e f0 ff ff       	jmp    80106224 <alltraps>

80107196 <vector219>:
.globl vector219
vector219:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $219
80107198:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010719d:	e9 82 f0 ff ff       	jmp    80106224 <alltraps>

801071a2 <vector220>:
.globl vector220
vector220:
  pushl $0
801071a2:	6a 00                	push   $0x0
  pushl $220
801071a4:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801071a9:	e9 76 f0 ff ff       	jmp    80106224 <alltraps>

801071ae <vector221>:
.globl vector221
vector221:
  pushl $0
801071ae:	6a 00                	push   $0x0
  pushl $221
801071b0:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801071b5:	e9 6a f0 ff ff       	jmp    80106224 <alltraps>

801071ba <vector222>:
.globl vector222
vector222:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $222
801071bc:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801071c1:	e9 5e f0 ff ff       	jmp    80106224 <alltraps>

801071c6 <vector223>:
.globl vector223
vector223:
  pushl $0
801071c6:	6a 00                	push   $0x0
  pushl $223
801071c8:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801071cd:	e9 52 f0 ff ff       	jmp    80106224 <alltraps>

801071d2 <vector224>:
.globl vector224
vector224:
  pushl $0
801071d2:	6a 00                	push   $0x0
  pushl $224
801071d4:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801071d9:	e9 46 f0 ff ff       	jmp    80106224 <alltraps>

801071de <vector225>:
.globl vector225
vector225:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $225
801071e0:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801071e5:	e9 3a f0 ff ff       	jmp    80106224 <alltraps>

801071ea <vector226>:
.globl vector226
vector226:
  pushl $0
801071ea:	6a 00                	push   $0x0
  pushl $226
801071ec:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801071f1:	e9 2e f0 ff ff       	jmp    80106224 <alltraps>

801071f6 <vector227>:
.globl vector227
vector227:
  pushl $0
801071f6:	6a 00                	push   $0x0
  pushl $227
801071f8:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801071fd:	e9 22 f0 ff ff       	jmp    80106224 <alltraps>

80107202 <vector228>:
.globl vector228
vector228:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $228
80107204:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107209:	e9 16 f0 ff ff       	jmp    80106224 <alltraps>

8010720e <vector229>:
.globl vector229
vector229:
  pushl $0
8010720e:	6a 00                	push   $0x0
  pushl $229
80107210:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107215:	e9 0a f0 ff ff       	jmp    80106224 <alltraps>

8010721a <vector230>:
.globl vector230
vector230:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $230
8010721c:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107221:	e9 fe ef ff ff       	jmp    80106224 <alltraps>

80107226 <vector231>:
.globl vector231
vector231:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $231
80107228:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010722d:	e9 f2 ef ff ff       	jmp    80106224 <alltraps>

80107232 <vector232>:
.globl vector232
vector232:
  pushl $0
80107232:	6a 00                	push   $0x0
  pushl $232
80107234:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107239:	e9 e6 ef ff ff       	jmp    80106224 <alltraps>

8010723e <vector233>:
.globl vector233
vector233:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $233
80107240:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107245:	e9 da ef ff ff       	jmp    80106224 <alltraps>

8010724a <vector234>:
.globl vector234
vector234:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $234
8010724c:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107251:	e9 ce ef ff ff       	jmp    80106224 <alltraps>

80107256 <vector235>:
.globl vector235
vector235:
  pushl $0
80107256:	6a 00                	push   $0x0
  pushl $235
80107258:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010725d:	e9 c2 ef ff ff       	jmp    80106224 <alltraps>

80107262 <vector236>:
.globl vector236
vector236:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $236
80107264:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107269:	e9 b6 ef ff ff       	jmp    80106224 <alltraps>

8010726e <vector237>:
.globl vector237
vector237:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $237
80107270:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107275:	e9 aa ef ff ff       	jmp    80106224 <alltraps>

8010727a <vector238>:
.globl vector238
vector238:
  pushl $0
8010727a:	6a 00                	push   $0x0
  pushl $238
8010727c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107281:	e9 9e ef ff ff       	jmp    80106224 <alltraps>

80107286 <vector239>:
.globl vector239
vector239:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $239
80107288:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010728d:	e9 92 ef ff ff       	jmp    80106224 <alltraps>

80107292 <vector240>:
.globl vector240
vector240:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $240
80107294:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107299:	e9 86 ef ff ff       	jmp    80106224 <alltraps>

8010729e <vector241>:
.globl vector241
vector241:
  pushl $0
8010729e:	6a 00                	push   $0x0
  pushl $241
801072a0:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801072a5:	e9 7a ef ff ff       	jmp    80106224 <alltraps>

801072aa <vector242>:
.globl vector242
vector242:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $242
801072ac:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801072b1:	e9 6e ef ff ff       	jmp    80106224 <alltraps>

801072b6 <vector243>:
.globl vector243
vector243:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $243
801072b8:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801072bd:	e9 62 ef ff ff       	jmp    80106224 <alltraps>

801072c2 <vector244>:
.globl vector244
vector244:
  pushl $0
801072c2:	6a 00                	push   $0x0
  pushl $244
801072c4:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801072c9:	e9 56 ef ff ff       	jmp    80106224 <alltraps>

801072ce <vector245>:
.globl vector245
vector245:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $245
801072d0:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801072d5:	e9 4a ef ff ff       	jmp    80106224 <alltraps>

801072da <vector246>:
.globl vector246
vector246:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $246
801072dc:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801072e1:	e9 3e ef ff ff       	jmp    80106224 <alltraps>

801072e6 <vector247>:
.globl vector247
vector247:
  pushl $0
801072e6:	6a 00                	push   $0x0
  pushl $247
801072e8:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801072ed:	e9 32 ef ff ff       	jmp    80106224 <alltraps>

801072f2 <vector248>:
.globl vector248
vector248:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $248
801072f4:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801072f9:	e9 26 ef ff ff       	jmp    80106224 <alltraps>

801072fe <vector249>:
.globl vector249
vector249:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $249
80107300:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107305:	e9 1a ef ff ff       	jmp    80106224 <alltraps>

8010730a <vector250>:
.globl vector250
vector250:
  pushl $0
8010730a:	6a 00                	push   $0x0
  pushl $250
8010730c:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107311:	e9 0e ef ff ff       	jmp    80106224 <alltraps>

80107316 <vector251>:
.globl vector251
vector251:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $251
80107318:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010731d:	e9 02 ef ff ff       	jmp    80106224 <alltraps>

80107322 <vector252>:
.globl vector252
vector252:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $252
80107324:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107329:	e9 f6 ee ff ff       	jmp    80106224 <alltraps>

8010732e <vector253>:
.globl vector253
vector253:
  pushl $0
8010732e:	6a 00                	push   $0x0
  pushl $253
80107330:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107335:	e9 ea ee ff ff       	jmp    80106224 <alltraps>

8010733a <vector254>:
.globl vector254
vector254:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $254
8010733c:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107341:	e9 de ee ff ff       	jmp    80106224 <alltraps>

80107346 <vector255>:
.globl vector255
vector255:
  pushl $0
80107346:	6a 00                	push   $0x0
  pushl $255
80107348:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010734d:	e9 d2 ee ff ff       	jmp    80106224 <alltraps>
80107352:	66 90                	xchg   %ax,%ax

80107354 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107354:	55                   	push   %ebp
80107355:	89 e5                	mov    %esp,%ebp
80107357:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010735a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010735d:	48                   	dec    %eax
8010735e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107362:	8b 45 08             	mov    0x8(%ebp),%eax
80107365:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107369:	8b 45 08             	mov    0x8(%ebp),%eax
8010736c:	c1 e8 10             	shr    $0x10,%eax
8010736f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107373:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107376:	0f 01 10             	lgdtl  (%eax)
}
80107379:	c9                   	leave  
8010737a:	c3                   	ret    

8010737b <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010737b:	55                   	push   %ebp
8010737c:	89 e5                	mov    %esp,%ebp
8010737e:	83 ec 04             	sub    $0x4,%esp
80107381:	8b 45 08             	mov    0x8(%ebp),%eax
80107384:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107388:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010738b:	0f 00 d8             	ltr    %ax
}
8010738e:	c9                   	leave  
8010738f:	c3                   	ret    

80107390 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107390:	55                   	push   %ebp
80107391:	89 e5                	mov    %esp,%ebp
80107393:	83 ec 04             	sub    $0x4,%esp
80107396:	8b 45 08             	mov    0x8(%ebp),%eax
80107399:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010739d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801073a0:	8e e8                	mov    %eax,%gs
}
801073a2:	c9                   	leave  
801073a3:	c3                   	ret    

801073a4 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
801073a4:	55                   	push   %ebp
801073a5:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801073a7:	8b 45 08             	mov    0x8(%ebp),%eax
801073aa:	0f 22 d8             	mov    %eax,%cr3
}
801073ad:	5d                   	pop    %ebp
801073ae:	c3                   	ret    

801073af <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801073af:	55                   	push   %ebp
801073b0:	89 e5                	mov    %esp,%ebp
801073b2:	8b 45 08             	mov    0x8(%ebp),%eax
801073b5:	05 00 00 00 80       	add    $0x80000000,%eax
801073ba:	5d                   	pop    %ebp
801073bb:	c3                   	ret    

801073bc <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801073bc:	55                   	push   %ebp
801073bd:	89 e5                	mov    %esp,%ebp
801073bf:	8b 45 08             	mov    0x8(%ebp),%eax
801073c2:	05 00 00 00 80       	add    $0x80000000,%eax
801073c7:	5d                   	pop    %ebp
801073c8:	c3                   	ret    

801073c9 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801073c9:	55                   	push   %ebp
801073ca:	89 e5                	mov    %esp,%ebp
801073cc:	53                   	push   %ebx
801073cd:	83 ec 24             	sub    $0x24,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801073d0:	e8 52 ba ff ff       	call   80102e27 <cpunum>
801073d5:	89 c2                	mov    %eax,%edx
801073d7:	89 d0                	mov    %edx,%eax
801073d9:	d1 e0                	shl    %eax
801073db:	01 d0                	add    %edx,%eax
801073dd:	c1 e0 04             	shl    $0x4,%eax
801073e0:	29 d0                	sub    %edx,%eax
801073e2:	c1 e0 02             	shl    $0x2,%eax
801073e5:	05 40 f9 10 80       	add    $0x8010f940,%eax
801073ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801073ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f0:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801073f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f9:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801073ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107402:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107409:	8a 50 7d             	mov    0x7d(%eax),%dl
8010740c:	83 e2 f0             	and    $0xfffffff0,%edx
8010740f:	83 ca 0a             	or     $0xa,%edx
80107412:	88 50 7d             	mov    %dl,0x7d(%eax)
80107415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107418:	8a 50 7d             	mov    0x7d(%eax),%dl
8010741b:	83 ca 10             	or     $0x10,%edx
8010741e:	88 50 7d             	mov    %dl,0x7d(%eax)
80107421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107424:	8a 50 7d             	mov    0x7d(%eax),%dl
80107427:	83 e2 9f             	and    $0xffffff9f,%edx
8010742a:	88 50 7d             	mov    %dl,0x7d(%eax)
8010742d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107430:	8a 50 7d             	mov    0x7d(%eax),%dl
80107433:	83 ca 80             	or     $0xffffff80,%edx
80107436:	88 50 7d             	mov    %dl,0x7d(%eax)
80107439:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743c:	8a 50 7e             	mov    0x7e(%eax),%dl
8010743f:	83 ca 0f             	or     $0xf,%edx
80107442:	88 50 7e             	mov    %dl,0x7e(%eax)
80107445:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107448:	8a 50 7e             	mov    0x7e(%eax),%dl
8010744b:	83 e2 ef             	and    $0xffffffef,%edx
8010744e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107454:	8a 50 7e             	mov    0x7e(%eax),%dl
80107457:	83 e2 df             	and    $0xffffffdf,%edx
8010745a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010745d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107460:	8a 50 7e             	mov    0x7e(%eax),%dl
80107463:	83 ca 40             	or     $0x40,%edx
80107466:	88 50 7e             	mov    %dl,0x7e(%eax)
80107469:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010746c:	8a 50 7e             	mov    0x7e(%eax),%dl
8010746f:	83 ca 80             	or     $0xffffff80,%edx
80107472:	88 50 7e             	mov    %dl,0x7e(%eax)
80107475:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107478:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010747c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010747f:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107486:	ff ff 
80107488:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107492:	00 00 
80107494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107497:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010749e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a1:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801074a7:	83 e2 f0             	and    $0xfffffff0,%edx
801074aa:	83 ca 02             	or     $0x2,%edx
801074ad:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b6:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801074bc:	83 ca 10             	or     $0x10,%edx
801074bf:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c8:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801074ce:	83 e2 9f             	and    $0xffffff9f,%edx
801074d1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074da:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801074e0:	83 ca 80             	or     $0xffffff80,%edx
801074e3:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801074e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ec:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801074f2:	83 ca 0f             	or     $0xf,%edx
801074f5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fe:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107504:	83 e2 ef             	and    $0xffffffef,%edx
80107507:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010750d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107510:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107516:	83 e2 df             	and    $0xffffffdf,%edx
80107519:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010751f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107522:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107528:	83 ca 40             	or     $0x40,%edx
8010752b:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107534:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010753a:	83 ca 80             	or     $0xffffff80,%edx
8010753d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107546:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010754d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107550:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107557:	ff ff 
80107559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010755c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107563:	00 00 
80107565:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107568:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010756f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107572:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107578:	83 e2 f0             	and    $0xfffffff0,%edx
8010757b:	83 ca 0a             	or     $0xa,%edx
8010757e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107587:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010758d:	83 ca 10             	or     $0x10,%edx
80107590:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107599:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010759f:	83 ca 60             	or     $0x60,%edx
801075a2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ab:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801075b1:	83 ca 80             	or     $0xffffff80,%edx
801075b4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801075ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075bd:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801075c3:	83 ca 0f             	or     $0xf,%edx
801075c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cf:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801075d5:	83 e2 ef             	and    $0xffffffef,%edx
801075d8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e1:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801075e7:	83 e2 df             	and    $0xffffffdf,%edx
801075ea:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801075f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f3:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801075f9:	83 ca 40             	or     $0x40,%edx
801075fc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107605:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010760b:	83 ca 80             	or     $0xffffff80,%edx
8010760e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107617:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010761e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107621:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107628:	ff ff 
8010762a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010762d:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107634:	00 00 
80107636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107639:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107640:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107643:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107649:	83 e2 f0             	and    $0xfffffff0,%edx
8010764c:	83 ca 02             	or     $0x2,%edx
8010764f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107658:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
8010765e:	83 ca 10             	or     $0x10,%edx
80107661:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010766a:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107670:	83 ca 60             	or     $0x60,%edx
80107673:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010767c:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80107682:	83 ca 80             	or     $0xffffff80,%edx
80107685:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010768b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010768e:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
80107694:	83 ca 0f             	or     $0xf,%edx
80107697:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010769d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a0:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
801076a6:	83 e2 ef             	and    $0xffffffef,%edx
801076a9:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b2:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
801076b8:	83 e2 df             	and    $0xffffffdf,%edx
801076bb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076c4:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
801076ca:	83 ca 40             	or     $0x40,%edx
801076cd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076d6:	8a 90 9e 00 00 00    	mov    0x9e(%eax),%dl
801076dc:	83 ca 80             	or     $0xffffff80,%edx
801076df:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801076e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076e8:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801076ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076f2:	05 b4 00 00 00       	add    $0xb4,%eax
801076f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801076fa:	81 c2 b4 00 00 00    	add    $0xb4,%edx
80107700:	c1 ea 10             	shr    $0x10,%edx
80107703:	88 d1                	mov    %dl,%cl
80107705:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107708:	81 c2 b4 00 00 00    	add    $0xb4,%edx
8010770e:	c1 ea 18             	shr    $0x18,%edx
80107711:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107714:	66 c7 83 88 00 00 00 	movw   $0x0,0x88(%ebx)
8010771b:	00 00 
8010771d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80107720:	66 89 83 8a 00 00 00 	mov    %ax,0x8a(%ebx)
80107727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010772a:	88 88 8c 00 00 00    	mov    %cl,0x8c(%eax)
80107730:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107733:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107739:	83 e1 f0             	and    $0xfffffff0,%ecx
8010773c:	83 c9 02             	or     $0x2,%ecx
8010773f:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107748:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
8010774e:	83 c9 10             	or     $0x10,%ecx
80107751:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010775a:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107760:	83 e1 9f             	and    $0xffffff9f,%ecx
80107763:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
80107769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010776c:	8a 88 8d 00 00 00    	mov    0x8d(%eax),%cl
80107772:	83 c9 80             	or     $0xffffff80,%ecx
80107775:	88 88 8d 00 00 00    	mov    %cl,0x8d(%eax)
8010777b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010777e:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107784:	83 e1 f0             	and    $0xfffffff0,%ecx
80107787:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010778d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107790:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
80107796:	83 e1 ef             	and    $0xffffffef,%ecx
80107799:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
8010779f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077a2:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
801077a8:	83 e1 df             	and    $0xffffffdf,%ecx
801077ab:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801077b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077b4:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
801077ba:	83 c9 40             	or     $0x40,%ecx
801077bd:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801077c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c6:	8a 88 8e 00 00 00    	mov    0x8e(%eax),%cl
801077cc:	83 c9 80             	or     $0xffffff80,%ecx
801077cf:	88 88 8e 00 00 00    	mov    %cl,0x8e(%eax)
801077d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d8:	88 90 8f 00 00 00    	mov    %dl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801077de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e1:	83 c0 70             	add    $0x70,%eax
801077e4:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
801077eb:	00 
801077ec:	89 04 24             	mov    %eax,(%esp)
801077ef:	e8 60 fb ff ff       	call   80107354 <lgdt>
  loadgs(SEG_KCPU << 3);
801077f4:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
801077fb:	e8 90 fb ff ff       	call   80107390 <loadgs>
  
  // Initialize cpu-local storage.
  cpu = c;
80107800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107803:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107809:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107810:	00 00 00 00 
}
80107814:	83 c4 24             	add    $0x24,%esp
80107817:	5b                   	pop    %ebx
80107818:	5d                   	pop    %ebp
80107819:	c3                   	ret    

8010781a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010781a:	55                   	push   %ebp
8010781b:	89 e5                	mov    %esp,%ebp
8010781d:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107820:	8b 45 0c             	mov    0xc(%ebp),%eax
80107823:	c1 e8 16             	shr    $0x16,%eax
80107826:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010782d:	8b 45 08             	mov    0x8(%ebp),%eax
80107830:	01 d0                	add    %edx,%eax
80107832:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107838:	8b 00                	mov    (%eax),%eax
8010783a:	83 e0 01             	and    $0x1,%eax
8010783d:	85 c0                	test   %eax,%eax
8010783f:	74 17                	je     80107858 <walkpgdir+0x3e>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107841:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107844:	8b 00                	mov    (%eax),%eax
80107846:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010784b:	89 04 24             	mov    %eax,(%esp)
8010784e:	e8 69 fb ff ff       	call   801073bc <p2v>
80107853:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107856:	eb 4b                	jmp    801078a3 <walkpgdir+0x89>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107858:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010785c:	74 0e                	je     8010786c <walkpgdir+0x52>
8010785e:	e8 3c b2 ff ff       	call   80102a9f <kalloc>
80107863:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107866:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010786a:	75 07                	jne    80107873 <walkpgdir+0x59>
      return 0;
8010786c:	b8 00 00 00 00       	mov    $0x0,%eax
80107871:	eb 47                	jmp    801078ba <walkpgdir+0xa0>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107873:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010787a:	00 
8010787b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107882:	00 
80107883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107886:	89 04 24             	mov    %eax,(%esp)
80107889:	e8 f0 d4 ff ff       	call   80104d7e <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010788e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107891:	89 04 24             	mov    %eax,(%esp)
80107894:	e8 16 fb ff ff       	call   801073af <v2p>
80107899:	89 c2                	mov    %eax,%edx
8010789b:	83 ca 07             	or     $0x7,%edx
8010789e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801078a1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801078a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801078a6:	c1 e8 0c             	shr    $0xc,%eax
801078a9:	25 ff 03 00 00       	and    $0x3ff,%eax
801078ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b8:	01 d0                	add    %edx,%eax
}
801078ba:	c9                   	leave  
801078bb:	c3                   	ret    

801078bc <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801078bc:	55                   	push   %ebp
801078bd:	89 e5                	mov    %esp,%ebp
801078bf:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
801078c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801078c5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801078cd:	8b 55 0c             	mov    0xc(%ebp),%edx
801078d0:	8b 45 10             	mov    0x10(%ebp),%eax
801078d3:	01 d0                	add    %edx,%eax
801078d5:	48                   	dec    %eax
801078d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801078db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801078de:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801078e5:	00 
801078e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801078ed:	8b 45 08             	mov    0x8(%ebp),%eax
801078f0:	89 04 24             	mov    %eax,(%esp)
801078f3:	e8 22 ff ff ff       	call   8010781a <walkpgdir>
801078f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
801078fb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801078ff:	75 07                	jne    80107908 <mappages+0x4c>
      return -1;
80107901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107906:	eb 46                	jmp    8010794e <mappages+0x92>
    if(*pte & PTE_P)
80107908:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010790b:	8b 00                	mov    (%eax),%eax
8010790d:	83 e0 01             	and    $0x1,%eax
80107910:	85 c0                	test   %eax,%eax
80107912:	74 0c                	je     80107920 <mappages+0x64>
      panic("remap");
80107914:	c7 04 24 70 87 10 80 	movl   $0x80108770,(%esp)
8010791b:	e8 16 8c ff ff       	call   80100536 <panic>
    *pte = pa | perm | PTE_P;
80107920:	8b 45 18             	mov    0x18(%ebp),%eax
80107923:	0b 45 14             	or     0x14(%ebp),%eax
80107926:	89 c2                	mov    %eax,%edx
80107928:	83 ca 01             	or     $0x1,%edx
8010792b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010792e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107933:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107936:	74 10                	je     80107948 <mappages+0x8c>
      break;
    a += PGSIZE;
80107938:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010793f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107946:	eb 96                	jmp    801078de <mappages+0x22>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107948:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107949:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010794e:	c9                   	leave  
8010794f:	c3                   	ret    

80107950 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107950:	55                   	push   %ebp
80107951:	89 e5                	mov    %esp,%ebp
80107953:	53                   	push   %ebx
80107954:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107957:	e8 43 b1 ff ff       	call   80102a9f <kalloc>
8010795c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010795f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107963:	75 0a                	jne    8010796f <setupkvm+0x1f>
    return 0;
80107965:	b8 00 00 00 00       	mov    $0x0,%eax
8010796a:	e9 98 00 00 00       	jmp    80107a07 <setupkvm+0xb7>
  memset(pgdir, 0, PGSIZE);
8010796f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107976:	00 
80107977:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010797e:	00 
8010797f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107982:	89 04 24             	mov    %eax,(%esp)
80107985:	e8 f4 d3 ff ff       	call   80104d7e <memset>
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010798a:	c7 04 24 00 00 00 0e 	movl   $0xe000000,(%esp)
80107991:	e8 26 fa ff ff       	call   801073bc <p2v>
80107996:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
8010799b:	76 0c                	jbe    801079a9 <setupkvm+0x59>
    panic("PHYSTOP too high");
8010799d:	c7 04 24 76 87 10 80 	movl   $0x80108776,(%esp)
801079a4:	e8 8d 8b ff ff       	call   80100536 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079a9:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
801079b0:	eb 49                	jmp    801079fb <setupkvm+0xab>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
801079b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801079b5:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
801079b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
801079bb:	8b 50 04             	mov    0x4(%eax),%edx
801079be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c1:	8b 58 08             	mov    0x8(%eax),%ebx
801079c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079c7:	8b 40 04             	mov    0x4(%eax),%eax
801079ca:	29 c3                	sub    %eax,%ebx
801079cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cf:	8b 00                	mov    (%eax),%eax
801079d1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801079d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
801079d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801079dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801079e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079e4:	89 04 24             	mov    %eax,(%esp)
801079e7:	e8 d0 fe ff ff       	call   801078bc <mappages>
801079ec:	85 c0                	test   %eax,%eax
801079ee:	79 07                	jns    801079f7 <setupkvm+0xa7>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801079f0:	b8 00 00 00 00       	mov    $0x0,%eax
801079f5:	eb 10                	jmp    80107a07 <setupkvm+0xb7>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801079f7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801079fb:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107a02:	72 ae                	jb     801079b2 <setupkvm+0x62>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80107a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107a07:	83 c4 34             	add    $0x34,%esp
80107a0a:	5b                   	pop    %ebx
80107a0b:	5d                   	pop    %ebp
80107a0c:	c3                   	ret    

80107a0d <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107a0d:	55                   	push   %ebp
80107a0e:	89 e5                	mov    %esp,%ebp
80107a10:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107a13:	e8 38 ff ff ff       	call   80107950 <setupkvm>
80107a18:	a3 18 2b 11 80       	mov    %eax,0x80112b18
  switchkvm();
80107a1d:	e8 02 00 00 00       	call   80107a24 <switchkvm>
}
80107a22:	c9                   	leave  
80107a23:	c3                   	ret    

80107a24 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107a24:	55                   	push   %ebp
80107a25:	89 e5                	mov    %esp,%ebp
80107a27:	83 ec 04             	sub    $0x4,%esp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107a2a:	a1 18 2b 11 80       	mov    0x80112b18,%eax
80107a2f:	89 04 24             	mov    %eax,(%esp)
80107a32:	e8 78 f9 ff ff       	call   801073af <v2p>
80107a37:	89 04 24             	mov    %eax,(%esp)
80107a3a:	e8 65 f9 ff ff       	call   801073a4 <lcr3>
}
80107a3f:	c9                   	leave  
80107a40:	c3                   	ret    

80107a41 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107a41:	55                   	push   %ebp
80107a42:	89 e5                	mov    %esp,%ebp
80107a44:	53                   	push   %ebx
80107a45:	83 ec 14             	sub    $0x14,%esp
  pushcli();
80107a48:	e8 30 d2 ff ff       	call   80104c7d <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107a4d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107a53:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107a5a:	83 c2 08             	add    $0x8,%edx
80107a5d:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80107a64:	83 c1 08             	add    $0x8,%ecx
80107a67:	c1 e9 10             	shr    $0x10,%ecx
80107a6a:	88 cb                	mov    %cl,%bl
80107a6c:	65 8b 0d 00 00 00 00 	mov    %gs:0x0,%ecx
80107a73:	83 c1 08             	add    $0x8,%ecx
80107a76:	c1 e9 18             	shr    $0x18,%ecx
80107a79:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107a80:	67 00 
80107a82:	66 89 90 a2 00 00 00 	mov    %dx,0xa2(%eax)
80107a89:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107a8f:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107a95:	83 e2 f0             	and    $0xfffffff0,%edx
80107a98:	83 ca 09             	or     $0x9,%edx
80107a9b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107aa1:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107aa7:	83 ca 10             	or     $0x10,%edx
80107aaa:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ab0:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107ab6:	83 e2 9f             	and    $0xffffff9f,%edx
80107ab9:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107abf:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107ac5:	83 ca 80             	or     $0xffffff80,%edx
80107ac8:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ace:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107ad4:	83 e2 f0             	and    $0xfffffff0,%edx
80107ad7:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107add:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107ae3:	83 e2 ef             	and    $0xffffffef,%edx
80107ae6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107aec:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107af2:	83 e2 df             	and    $0xffffffdf,%edx
80107af5:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107afb:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107b01:	83 ca 40             	or     $0x40,%edx
80107b04:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107b0a:	8a 90 a6 00 00 00    	mov    0xa6(%eax),%dl
80107b10:	83 e2 7f             	and    $0x7f,%edx
80107b13:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107b19:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107b1f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b25:	8a 90 a5 00 00 00    	mov    0xa5(%eax),%dl
80107b2b:	83 e2 ef             	and    $0xffffffef,%edx
80107b2e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107b34:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b3a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107b40:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107b46:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80107b4d:	8b 52 08             	mov    0x8(%edx),%edx
80107b50:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107b56:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107b59:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
80107b60:	e8 16 f8 ff ff       	call   8010737b <ltr>
  if(p->pgdir == 0)
80107b65:	8b 45 08             	mov    0x8(%ebp),%eax
80107b68:	8b 40 04             	mov    0x4(%eax),%eax
80107b6b:	85 c0                	test   %eax,%eax
80107b6d:	75 0c                	jne    80107b7b <switchuvm+0x13a>
    panic("switchuvm: no pgdir");
80107b6f:	c7 04 24 87 87 10 80 	movl   $0x80108787,(%esp)
80107b76:	e8 bb 89 ff ff       	call   80100536 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107b7b:	8b 45 08             	mov    0x8(%ebp),%eax
80107b7e:	8b 40 04             	mov    0x4(%eax),%eax
80107b81:	89 04 24             	mov    %eax,(%esp)
80107b84:	e8 26 f8 ff ff       	call   801073af <v2p>
80107b89:	89 04 24             	mov    %eax,(%esp)
80107b8c:	e8 13 f8 ff ff       	call   801073a4 <lcr3>
  popcli();
80107b91:	e8 2d d1 ff ff       	call   80104cc3 <popcli>
}
80107b96:	83 c4 14             	add    $0x14,%esp
80107b99:	5b                   	pop    %ebx
80107b9a:	5d                   	pop    %ebp
80107b9b:	c3                   	ret    

80107b9c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107b9c:	55                   	push   %ebp
80107b9d:	89 e5                	mov    %esp,%ebp
80107b9f:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107ba2:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107ba9:	76 0c                	jbe    80107bb7 <inituvm+0x1b>
    panic("inituvm: more than a page");
80107bab:	c7 04 24 9b 87 10 80 	movl   $0x8010879b,(%esp)
80107bb2:	e8 7f 89 ff ff       	call   80100536 <panic>
  mem = kalloc();
80107bb7:	e8 e3 ae ff ff       	call   80102a9f <kalloc>
80107bbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107bbf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107bc6:	00 
80107bc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107bce:	00 
80107bcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd2:	89 04 24             	mov    %eax,(%esp)
80107bd5:	e8 a4 d1 ff ff       	call   80104d7e <memset>
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdd:	89 04 24             	mov    %eax,(%esp)
80107be0:	e8 ca f7 ff ff       	call   801073af <v2p>
80107be5:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107bec:	00 
80107bed:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107bf1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107bf8:	00 
80107bf9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107c00:	00 
80107c01:	8b 45 08             	mov    0x8(%ebp),%eax
80107c04:	89 04 24             	mov    %eax,(%esp)
80107c07:	e8 b0 fc ff ff       	call   801078bc <mappages>
  memmove(mem, init, sz);
80107c0c:	8b 45 10             	mov    0x10(%ebp),%eax
80107c0f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107c13:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c16:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1d:	89 04 24             	mov    %eax,(%esp)
80107c20:	e8 25 d2 ff ff       	call   80104e4a <memmove>
}
80107c25:	c9                   	leave  
80107c26:	c3                   	ret    

80107c27 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107c27:	55                   	push   %ebp
80107c28:	89 e5                	mov    %esp,%ebp
80107c2a:	53                   	push   %ebx
80107c2b:	83 ec 24             	sub    $0x24,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c31:	25 ff 0f 00 00       	and    $0xfff,%eax
80107c36:	85 c0                	test   %eax,%eax
80107c38:	74 0c                	je     80107c46 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107c3a:	c7 04 24 b8 87 10 80 	movl   $0x801087b8,(%esp)
80107c41:	e8 f0 88 ff ff       	call   80100536 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107c46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107c4d:	e9 ad 00 00 00       	jmp    80107cff <loaduvm+0xd8>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c55:	8b 55 0c             	mov    0xc(%ebp),%edx
80107c58:	01 d0                	add    %edx,%eax
80107c5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107c61:	00 
80107c62:	89 44 24 04          	mov    %eax,0x4(%esp)
80107c66:	8b 45 08             	mov    0x8(%ebp),%eax
80107c69:	89 04 24             	mov    %eax,(%esp)
80107c6c:	e8 a9 fb ff ff       	call   8010781a <walkpgdir>
80107c71:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107c74:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107c78:	75 0c                	jne    80107c86 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80107c7a:	c7 04 24 db 87 10 80 	movl   $0x801087db,(%esp)
80107c81:	e8 b0 88 ff ff       	call   80100536 <panic>
    pa = PTE_ADDR(*pte);
80107c86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c89:	8b 00                	mov    (%eax),%eax
80107c8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c90:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c96:	8b 55 18             	mov    0x18(%ebp),%edx
80107c99:	89 d1                	mov    %edx,%ecx
80107c9b:	29 c1                	sub    %eax,%ecx
80107c9d:	89 c8                	mov    %ecx,%eax
80107c9f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107ca4:	77 11                	ja     80107cb7 <loaduvm+0x90>
      n = sz - i;
80107ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca9:	8b 55 18             	mov    0x18(%ebp),%edx
80107cac:	89 d1                	mov    %edx,%ecx
80107cae:	29 c1                	sub    %eax,%ecx
80107cb0:	89 c8                	mov    %ecx,%eax
80107cb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107cb5:	eb 07                	jmp    80107cbe <loaduvm+0x97>
    else
      n = PGSIZE;
80107cb7:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80107cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc1:	8b 55 14             	mov    0x14(%ebp),%edx
80107cc4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80107cc7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107cca:	89 04 24             	mov    %eax,(%esp)
80107ccd:	e8 ea f6 ff ff       	call   801073bc <p2v>
80107cd2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107cd5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107cd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80107ce1:	8b 45 10             	mov    0x10(%ebp),%eax
80107ce4:	89 04 24             	mov    %eax,(%esp)
80107ce7:	e8 3d a0 ff ff       	call   80101d29 <readi>
80107cec:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107cef:	74 07                	je     80107cf8 <loaduvm+0xd1>
      return -1;
80107cf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cf6:	eb 18                	jmp    80107d10 <loaduvm+0xe9>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80107cf8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d02:	3b 45 18             	cmp    0x18(%ebp),%eax
80107d05:	0f 82 47 ff ff ff    	jb     80107c52 <loaduvm+0x2b>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80107d0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d10:	83 c4 24             	add    $0x24,%esp
80107d13:	5b                   	pop    %ebx
80107d14:	5d                   	pop    %ebp
80107d15:	c3                   	ret    

80107d16 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107d16:	55                   	push   %ebp
80107d17:	89 e5                	mov    %esp,%ebp
80107d19:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107d1c:	8b 45 10             	mov    0x10(%ebp),%eax
80107d1f:	85 c0                	test   %eax,%eax
80107d21:	79 0a                	jns    80107d2d <allocuvm+0x17>
    return 0;
80107d23:	b8 00 00 00 00       	mov    $0x0,%eax
80107d28:	e9 c1 00 00 00       	jmp    80107dee <allocuvm+0xd8>
  if(newsz < oldsz)
80107d2d:	8b 45 10             	mov    0x10(%ebp),%eax
80107d30:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107d33:	73 08                	jae    80107d3d <allocuvm+0x27>
    return oldsz;
80107d35:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d38:	e9 b1 00 00 00       	jmp    80107dee <allocuvm+0xd8>

  a = PGROUNDUP(oldsz);
80107d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d40:	05 ff 0f 00 00       	add    $0xfff,%eax
80107d45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107d4d:	e9 8d 00 00 00       	jmp    80107ddf <allocuvm+0xc9>
    mem = kalloc();
80107d52:	e8 48 ad ff ff       	call   80102a9f <kalloc>
80107d57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107d5a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d5e:	75 2c                	jne    80107d8c <allocuvm+0x76>
      cprintf("allocuvm out of memory\n");
80107d60:	c7 04 24 f9 87 10 80 	movl   $0x801087f9,(%esp)
80107d67:	e8 35 86 ff ff       	call   801003a1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80107d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107d6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107d73:	8b 45 10             	mov    0x10(%ebp),%eax
80107d76:	89 44 24 04          	mov    %eax,0x4(%esp)
80107d7a:	8b 45 08             	mov    0x8(%ebp),%eax
80107d7d:	89 04 24             	mov    %eax,(%esp)
80107d80:	e8 6b 00 00 00       	call   80107df0 <deallocuvm>
      return 0;
80107d85:	b8 00 00 00 00       	mov    $0x0,%eax
80107d8a:	eb 62                	jmp    80107dee <allocuvm+0xd8>
    }
    memset(mem, 0, PGSIZE);
80107d8c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107d93:	00 
80107d94:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107d9b:	00 
80107d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d9f:	89 04 24             	mov    %eax,(%esp)
80107da2:	e8 d7 cf ff ff       	call   80104d7e <memset>
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107da7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107daa:	89 04 24             	mov    %eax,(%esp)
80107dad:	e8 fd f5 ff ff       	call   801073af <v2p>
80107db2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107db5:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80107dbc:	00 
80107dbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
80107dc1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107dc8:	00 
80107dc9:	89 54 24 04          	mov    %edx,0x4(%esp)
80107dcd:	8b 45 08             	mov    0x8(%ebp),%eax
80107dd0:	89 04 24             	mov    %eax,(%esp)
80107dd3:	e8 e4 fa ff ff       	call   801078bc <mappages>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80107dd8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de2:	3b 45 10             	cmp    0x10(%ebp),%eax
80107de5:	0f 82 67 ff ff ff    	jb     80107d52 <allocuvm+0x3c>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80107deb:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107dee:	c9                   	leave  
80107def:	c3                   	ret    

80107df0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107df0:	55                   	push   %ebp
80107df1:	89 e5                	mov    %esp,%ebp
80107df3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80107df6:	8b 45 10             	mov    0x10(%ebp),%eax
80107df9:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107dfc:	72 08                	jb     80107e06 <deallocuvm+0x16>
    return oldsz;
80107dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e01:	e9 a4 00 00 00       	jmp    80107eaa <deallocuvm+0xba>

  a = PGROUNDUP(newsz);
80107e06:	8b 45 10             	mov    0x10(%ebp),%eax
80107e09:	05 ff 0f 00 00       	add    $0xfff,%eax
80107e0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e13:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107e16:	e9 80 00 00 00       	jmp    80107e9b <deallocuvm+0xab>
    pte = walkpgdir(pgdir, (char*)a, 0);
80107e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107e25:	00 
80107e26:	89 44 24 04          	mov    %eax,0x4(%esp)
80107e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80107e2d:	89 04 24             	mov    %eax,(%esp)
80107e30:	e8 e5 f9 ff ff       	call   8010781a <walkpgdir>
80107e35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107e38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107e3c:	75 09                	jne    80107e47 <deallocuvm+0x57>
      a += (NPTENTRIES - 1) * PGSIZE;
80107e3e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80107e45:	eb 4d                	jmp    80107e94 <deallocuvm+0xa4>
    else if((*pte & PTE_P) != 0){
80107e47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e4a:	8b 00                	mov    (%eax),%eax
80107e4c:	83 e0 01             	and    $0x1,%eax
80107e4f:	85 c0                	test   %eax,%eax
80107e51:	74 41                	je     80107e94 <deallocuvm+0xa4>
      pa = PTE_ADDR(*pte);
80107e53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e56:	8b 00                	mov    (%eax),%eax
80107e58:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80107e60:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107e64:	75 0c                	jne    80107e72 <deallocuvm+0x82>
        panic("kfree");
80107e66:	c7 04 24 11 88 10 80 	movl   $0x80108811,(%esp)
80107e6d:	e8 c4 86 ff ff       	call   80100536 <panic>
      char *v = p2v(pa);
80107e72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107e75:	89 04 24             	mov    %eax,(%esp)
80107e78:	e8 3f f5 ff ff       	call   801073bc <p2v>
80107e7d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107e80:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107e83:	89 04 24             	mov    %eax,(%esp)
80107e86:	e8 7b ab ff ff       	call   80102a06 <kfree>
      *pte = 0;
80107e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80107e94:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e9e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107ea1:	0f 82 74 ff ff ff    	jb     80107e1b <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80107ea7:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107eaa:	c9                   	leave  
80107eab:	c3                   	ret    

80107eac <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107eac:	55                   	push   %ebp
80107ead:	89 e5                	mov    %esp,%ebp
80107eaf:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80107eb2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107eb6:	75 0c                	jne    80107ec4 <freevm+0x18>
    panic("freevm: no pgdir");
80107eb8:	c7 04 24 17 88 10 80 	movl   $0x80108817,(%esp)
80107ebf:	e8 72 86 ff ff       	call   80100536 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80107ec4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107ecb:	00 
80107ecc:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80107ed3:	80 
80107ed4:	8b 45 08             	mov    0x8(%ebp),%eax
80107ed7:	89 04 24             	mov    %eax,(%esp)
80107eda:	e8 11 ff ff ff       	call   80107df0 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80107edf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ee6:	eb 47                	jmp    80107f2f <freevm+0x83>
    if(pgdir[i] & PTE_P){
80107ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eeb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80107ef5:	01 d0                	add    %edx,%eax
80107ef7:	8b 00                	mov    (%eax),%eax
80107ef9:	83 e0 01             	and    $0x1,%eax
80107efc:	85 c0                	test   %eax,%eax
80107efe:	74 2c                	je     80107f2c <freevm+0x80>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80107f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f03:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f0d:	01 d0                	add    %edx,%eax
80107f0f:	8b 00                	mov    (%eax),%eax
80107f11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107f16:	89 04 24             	mov    %eax,(%esp)
80107f19:	e8 9e f4 ff ff       	call   801073bc <p2v>
80107f1e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107f21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f24:	89 04 24             	mov    %eax,(%esp)
80107f27:	e8 da aa ff ff       	call   80102a06 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107f2c:	ff 45 f4             	incl   -0xc(%ebp)
80107f2f:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107f36:	76 b0                	jbe    80107ee8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80107f38:	8b 45 08             	mov    0x8(%ebp),%eax
80107f3b:	89 04 24             	mov    %eax,(%esp)
80107f3e:	e8 c3 aa ff ff       	call   80102a06 <kfree>
}
80107f43:	c9                   	leave  
80107f44:	c3                   	ret    

80107f45 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107f45:	55                   	push   %ebp
80107f46:	89 e5                	mov    %esp,%ebp
80107f48:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107f4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107f52:	00 
80107f53:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f56:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f5d:	89 04 24             	mov    %eax,(%esp)
80107f60:	e8 b5 f8 ff ff       	call   8010781a <walkpgdir>
80107f65:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107f68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107f6c:	75 0c                	jne    80107f7a <clearpteu+0x35>
    panic("clearpteu");
80107f6e:	c7 04 24 28 88 10 80 	movl   $0x80108828,(%esp)
80107f75:	e8 bc 85 ff ff       	call   80100536 <panic>
  *pte &= ~PTE_U;
80107f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7d:	8b 00                	mov    (%eax),%eax
80107f7f:	89 c2                	mov    %eax,%edx
80107f81:	83 e2 fb             	and    $0xfffffffb,%edx
80107f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f87:	89 10                	mov    %edx,(%eax)
}
80107f89:	c9                   	leave  
80107f8a:	c3                   	ret    

80107f8b <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107f8b:	55                   	push   %ebp
80107f8c:	89 e5                	mov    %esp,%ebp
80107f8e:	53                   	push   %ebx
80107f8f:	83 ec 44             	sub    $0x44,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107f92:	e8 b9 f9 ff ff       	call   80107950 <setupkvm>
80107f97:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f9a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f9e:	75 0a                	jne    80107faa <copyuvm+0x1f>
    return 0;
80107fa0:	b8 00 00 00 00       	mov    $0x0,%eax
80107fa5:	e9 fd 00 00 00       	jmp    801080a7 <copyuvm+0x11c>
  for(i = 0; i < sz; i += PGSIZE){
80107faa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107fb1:	e9 cc 00 00 00       	jmp    80108082 <copyuvm+0xf7>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107fb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80107fc0:	00 
80107fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80107fc5:	8b 45 08             	mov    0x8(%ebp),%eax
80107fc8:	89 04 24             	mov    %eax,(%esp)
80107fcb:	e8 4a f8 ff ff       	call   8010781a <walkpgdir>
80107fd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107fd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107fd7:	75 0c                	jne    80107fe5 <copyuvm+0x5a>
      panic("copyuvm: pte should exist");
80107fd9:	c7 04 24 32 88 10 80 	movl   $0x80108832,(%esp)
80107fe0:	e8 51 85 ff ff       	call   80100536 <panic>
    if(!(*pte & PTE_P))
80107fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107fe8:	8b 00                	mov    (%eax),%eax
80107fea:	83 e0 01             	and    $0x1,%eax
80107fed:	85 c0                	test   %eax,%eax
80107fef:	75 0c                	jne    80107ffd <copyuvm+0x72>
      panic("copyuvm: page not present");
80107ff1:	c7 04 24 4c 88 10 80 	movl   $0x8010884c,(%esp)
80107ff8:	e8 39 85 ff ff       	call   80100536 <panic>
    pa = PTE_ADDR(*pte);
80107ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108000:	8b 00                	mov    (%eax),%eax
80108002:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108007:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010800a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010800d:	8b 00                	mov    (%eax),%eax
8010800f:	25 ff 0f 00 00       	and    $0xfff,%eax
80108014:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108017:	e8 83 aa ff ff       	call   80102a9f <kalloc>
8010801c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010801f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108023:	74 6e                	je     80108093 <copyuvm+0x108>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108025:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108028:	89 04 24             	mov    %eax,(%esp)
8010802b:	e8 8c f3 ff ff       	call   801073bc <p2v>
80108030:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108037:	00 
80108038:	89 44 24 04          	mov    %eax,0x4(%esp)
8010803c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010803f:	89 04 24             	mov    %eax,(%esp)
80108042:	e8 03 ce ff ff       	call   80104e4a <memmove>
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108047:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010804a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010804d:	89 04 24             	mov    %eax,(%esp)
80108050:	e8 5a f3 ff ff       	call   801073af <v2p>
80108055:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108058:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010805c:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108060:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108067:	00 
80108068:	89 54 24 04          	mov    %edx,0x4(%esp)
8010806c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010806f:	89 04 24             	mov    %eax,(%esp)
80108072:	e8 45 f8 ff ff       	call   801078bc <mappages>
80108077:	85 c0                	test   %eax,%eax
80108079:	78 1b                	js     80108096 <copyuvm+0x10b>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010807b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108085:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108088:	0f 82 28 ff ff ff    	jb     80107fb6 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010808e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108091:	eb 14                	jmp    801080a7 <copyuvm+0x11c>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108093:	90                   	nop
80108094:	eb 01                	jmp    80108097 <copyuvm+0x10c>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108096:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108097:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010809a:	89 04 24             	mov    %eax,(%esp)
8010809d:	e8 0a fe ff ff       	call   80107eac <freevm>
  return 0;
801080a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080a7:	83 c4 44             	add    $0x44,%esp
801080aa:	5b                   	pop    %ebx
801080ab:	5d                   	pop    %ebp
801080ac:	c3                   	ret    

801080ad <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801080ad:	55                   	push   %ebp
801080ae:	89 e5                	mov    %esp,%ebp
801080b0:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801080b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801080ba:	00 
801080bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801080be:	89 44 24 04          	mov    %eax,0x4(%esp)
801080c2:	8b 45 08             	mov    0x8(%ebp),%eax
801080c5:	89 04 24             	mov    %eax,(%esp)
801080c8:	e8 4d f7 ff ff       	call   8010781a <walkpgdir>
801080cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801080d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d3:	8b 00                	mov    (%eax),%eax
801080d5:	83 e0 01             	and    $0x1,%eax
801080d8:	85 c0                	test   %eax,%eax
801080da:	75 07                	jne    801080e3 <uva2ka+0x36>
    return 0;
801080dc:	b8 00 00 00 00       	mov    $0x0,%eax
801080e1:	eb 25                	jmp    80108108 <uva2ka+0x5b>
  if((*pte & PTE_U) == 0)
801080e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e6:	8b 00                	mov    (%eax),%eax
801080e8:	83 e0 04             	and    $0x4,%eax
801080eb:	85 c0                	test   %eax,%eax
801080ed:	75 07                	jne    801080f6 <uva2ka+0x49>
    return 0;
801080ef:	b8 00 00 00 00       	mov    $0x0,%eax
801080f4:	eb 12                	jmp    80108108 <uva2ka+0x5b>
  return (char*)p2v(PTE_ADDR(*pte));
801080f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f9:	8b 00                	mov    (%eax),%eax
801080fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108100:	89 04 24             	mov    %eax,(%esp)
80108103:	e8 b4 f2 ff ff       	call   801073bc <p2v>
}
80108108:	c9                   	leave  
80108109:	c3                   	ret    

8010810a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010810a:	55                   	push   %ebp
8010810b:	89 e5                	mov    %esp,%ebp
8010810d:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108110:	8b 45 10             	mov    0x10(%ebp),%eax
80108113:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108116:	e9 89 00 00 00       	jmp    801081a4 <copyout+0x9a>
    va0 = (uint)PGROUNDDOWN(va);
8010811b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010811e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108123:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108126:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108129:	89 44 24 04          	mov    %eax,0x4(%esp)
8010812d:	8b 45 08             	mov    0x8(%ebp),%eax
80108130:	89 04 24             	mov    %eax,(%esp)
80108133:	e8 75 ff ff ff       	call   801080ad <uva2ka>
80108138:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010813b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010813f:	75 07                	jne    80108148 <copyout+0x3e>
      return -1;
80108141:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108146:	eb 6b                	jmp    801081b3 <copyout+0xa9>
    n = PGSIZE - (va - va0);
80108148:	8b 45 0c             	mov    0xc(%ebp),%eax
8010814b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010814e:	89 d1                	mov    %edx,%ecx
80108150:	29 c1                	sub    %eax,%ecx
80108152:	89 c8                	mov    %ecx,%eax
80108154:	05 00 10 00 00       	add    $0x1000,%eax
80108159:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010815c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010815f:	3b 45 14             	cmp    0x14(%ebp),%eax
80108162:	76 06                	jbe    8010816a <copyout+0x60>
      n = len;
80108164:	8b 45 14             	mov    0x14(%ebp),%eax
80108167:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010816a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010816d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108170:	29 c2                	sub    %eax,%edx
80108172:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108175:	01 c2                	add    %eax,%edx
80108177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010817a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010817e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108181:	89 44 24 04          	mov    %eax,0x4(%esp)
80108185:	89 14 24             	mov    %edx,(%esp)
80108188:	e8 bd cc ff ff       	call   80104e4a <memmove>
    len -= n;
8010818d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108190:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108193:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108196:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108199:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010819c:	05 00 10 00 00       	add    $0x1000,%eax
801081a1:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801081a4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801081a8:	0f 85 6d ff ff ff    	jne    8010811b <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801081ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081b3:	c9                   	leave  
801081b4:	c3                   	ret    
