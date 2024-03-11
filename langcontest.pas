{$CALLING CDECL} { lets pretend we're a C compiler }
program langcontest;

type
  Talmost_efi_system_table_but_not_quite = record
    load_idt: procedure(const buffer: pointer; const size: word);
    enable_interrupts: procedure;
    disable_intrerrupts: procedure;
    iretq: procedure(const localsize: longint);
  end;
  Palmost_efi_system_table_but_not_quite = ^Talmost_efi_system_table_but_not_quite;

type
  Tidt_entry = packed record
    offs_low: word;
    selector: word;
    always_zero: byte;
    type_attr: byte;
    offs_middle: word;
    offs_high: dword;
    reserved: dword;
  end;
  Pidt_entry = ^Tidt_entry;

var
  systab: Palmost_efi_system_table_but_not_quite;
  idt: array[0..48-1] of Tidt_entry;
  counter: word;

procedure isr_handler; noreturn; { the noreturn keyword is optional }
var
  s: pbyte;
begin
  inc(counter);
  if counter=100 then
    begin
      counter:=0;
      s:=pointer($0b8006);
      while s >= pointer($b8000) do
        begin
          if s^=$39 then
            s^:=$30
          else
            begin
              inc(s^);
              break;
            end;
          dec(s,2);
        end;
    end;
  systab^.iretq(0);
end;

procedure start(_st: Palmost_efi_system_table_but_not_quite); public name '_START';
var
  ie: Pidt_entry; 
  isrh: ptruint;
begin
  systab:=_st;
  ie:=@idt[32];
  isrh:=ptruint(@isr_handler);

  with ie^ do
    begin
      offs_low:=word(isrh);
      selector:=32;
      type_attr:=$8e;
      offs_middle:=isrh shr 16;
      offs_high:=isrh shr 32;
    end;

  pqword($0b8000)[0]:=$0730073007300730;

  _st^.load_idt(@idt,sizeof(idt));
  _st^.enable_interrupts;

  repeat
{$ifdef cpux64}
    asm
      hlt;
    end;
{$endif}
  until false;
end;

begin
  { * empty main as startup code is bypassed, see "start" above * }
end.
