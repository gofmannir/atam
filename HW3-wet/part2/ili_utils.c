#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
// <STUDENT FILL> - HINT: USE INLINE ASSEMBLY
    __asm__("sidt %0" : "=m"(*idtr));
// </STUDENT FILL>
}

void my_load_idt(struct desc_ptr *idtr) {
// <STUDENT FILL> - HINT: USE INLINE ASSEMBLY
    /*
     * lidt (Load IDT Register) sets the CPU’s IDT pointer to whatever is
     * specified in *idtr.
     */
    __asm__("lidt %0" : : "m"(*idtr));
// <STUDENT FILL>
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
// <STUDENT FILL> - HINT: NO NEED FOR INLINE ASSEMBLY
    gate->offset_low    = (u16)(addr & 0xFFFF);
    gate->offset_middle = (u16)((addr >> 16) & 0xFFFF);
    gate->offset_high   = (u32)((addr >> 32) & 0xFFFFFFFF);
// </STUDENT FILL>
}

unsigned long my_get_gate_offset(gate_desc *gate) {
// <STUDENT FILL> - HINT: NO NEED FOR INLINE ASSEMBLY
    unsigned long offset;
    
    offset  = (unsigned long)gate->offset_low;
    offset |= (unsigned long)gate->offset_middle << 16;
    offset |= (unsigned long)gate->offset_high   << 32;
    
    return offset;
// </STUDENT FILL>
}
