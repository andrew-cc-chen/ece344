//#include <types.h>
//#include <kern/errno.h>
//#include <lib.h>
//#include <addrspace.h>
//#include <vm.h>
//
//
///////
//
//#include <machine/spl.h>
#include <types.h>
#include <kern/errno.h>
#include <lib.h>
#include <thread.h>
#include <curthread.h>
#include <addrspace.h>
#include <vm.h>
#include <machine/spl.h>
#include <machine/tlb.h>
/////

/*
 * Note! If OPT_DUMBVM is set, as is the case until you start the VM
 * assignment, this file is not compiled or linked or in any way
 * used. The cheesy hack versions in dumbvm.c are used instead.
 */

//struct addrspace *
//as_create(void)
//{
//	struct addrspace *as = kmalloc(sizeof(struct addrspace));
//	if (as==NULL) {
//		return NULL;
//	}
//
//	/*
//	 * Initialize as needed.
//	 */
//
//	return as;
//}
//
//int
//as_copy(struct addrspace *old, struct addrspace **ret)
//{
//	struct addrspace *newas;
//
//	newas = as_create();
//	if (newas==NULL) {
//		return ENOMEM;
//	}
//
//	/*
//	 * Write this.
//	 */
//
//	(void)old;
//	
//	*ret = newas;
//	return 0;
//}
//
//void
//as_destroy(struct addrspace *as)
//{
//	/*
//	 * Clean up as needed.
//	 */
//	
//	kfree(as);
//}
//
//void
//as_activate(struct addrspace *as)
//{
//	/*
//	 * Write this.
//	 */
//
//	(void)as;  // suppress warning until code gets written
//}
//
///*
// * Set up a segment at virtual address VADDR of size MEMSIZE. The
// * segment in memory extends from VADDR up to (but not including)
// * VADDR+MEMSIZE.
// *
// * The READABLE, WRITEABLE, and EXECUTABLE flags are set if read,
// * write, or execute permission should be set on the segment. At the
// * moment, these are ignored. When you write the VM system, you may
// * want to implement them.
// */
//int
//as_define_region(struct addrspace *as, vaddr_t vaddr, size_t sz,
//		 int readable, int writeable, int executable)
//{
//	/*
//	 * Write this.
//	 */
//
//	(void)as;
//	(void)vaddr;
//	(void)sz;
//	(void)readable;
//	(void)writeable;
//	(void)executable;
//	return EUNIMP;
//}
//
//int
//as_prepare_load(struct addrspace *as)
//{
//	/*
//	 * Write this.
//	 */
//
//	(void)as;
//	return 0;
//}
//
//int
//as_complete_load(struct addrspace *as)
//{
//	/*
//	 * Write this.
//	 */
//
//	(void)as;
//	return 0;
//}
//
//int
//as_define_stack(struct addrspace *as, vaddr_t *stackptr)
//{
//	/*
//	 * Write this.
//	 */
//
//	(void)as;
//
//	/* Initial user-level stack pointer */
//	*stackptr = USERSTACK;
//	
//	return 0;
//}


//////////////////////

/* under dumbvm, always have 48k of user stack */
#define DUMBVM_STACKPAGES    12

/*  initialize the address space struct */
struct addrspace *
as_create(char *progname) {
    struct addrspace *as = kmalloc(sizeof (struct addrspace));
    if (as == NULL) {
        return NULL;
    }
    as->program_name = progname;
    as->head_of_page_table = NULL;
    as->stack.region_start = (vaddr_t) 0;
    as->stack.region_end = (vaddr_t) 0;
    as->stack.offset_attribute = 0;
    as->stack.file_size_attribute = 0;
    as->heap.region_start = (vaddr_t) 0;
    as->heap.region_end = (vaddr_t) 0;
    as->heap.offset_attribute = 0;
    as->heap.file_size_attribute = 0;
    as->text.region_start = (vaddr_t) 0;
    as->text.region_end = (vaddr_t) 0;
    as->text.offset_attribute = 0;
    as->text.file_size_attribute = 0;
    as->data.region_start = (vaddr_t) 0;
    as->data.region_end = (vaddr_t) 0;
    as->data.offset_attribute = 0;
    as->data.file_size_attribute = 0;


    return as;
}

/*  remove the given address space  */
void
as_destroy(struct addrspace *as) {
    assert(as != NULL);


    //free page table linked list
    int spl;
    spl = splhigh();
    struct page_table_entry* temp;
    struct page_table_entry* cur = as->head_of_page_table;
    if (cur == NULL) {
        kfree(as);
        return;
    }

    if (cur->next_page_table_entry == NULL) {
        update_coremap(cur->page_table_entry_paddr);
        kfree(cur);
        kfree(as);
        return;
    }

    while (cur != NULL && cur->next_page_table_entry != NULL) {
        temp = cur;
        cur = cur->next_page_table_entry;

        update_coremap(cur->page_table_entry_paddr);
        //free the pte pointer --- previously malloced
        kfree(temp);
    }

    update_coremap(cur->page_table_entry_paddr);
    kfree(cur);
    kfree(as);
    as = NULL;
    splx(spl);
}

void
as_activate(struct addrspace *as) {
    int i, spl;

    (void) as;

    spl = splhigh();

    for (i = 0; i < NUM_TLB; i++) {
        TLB_Write(TLBHI_INVALID(i), TLBLO_INVALID(), i);
    }

    splx(spl);
}

/*  define the three regions (text, data, heap) NOT REAL DATA --- JUST BOUNDARIES
        REMEMBER TO INCREMENT THE PARAMETER ADDRESS ACCORDINGLY WHEN CALLING IT  */
int
as_define_region(struct addrspace *as, vaddr_t vaddr, size_t sz,
        int readable, int writeable, int executable, u_int32_t offset, u_int32_t file_size)//donezo
{
    size_t npages;

    /* Align the region. First, the base... */
    sz += vaddr & ~(vaddr_t) PAGE_FRAME;
    vaddr &= PAGE_FRAME;

    /* ...and now the length. */
    sz = (sz + PAGE_SIZE - 1) & PAGE_FRAME; //memsize

    npages = sz / PAGE_SIZE;

    /* We don't use these - all pages are read-write */
    (void) readable;
    (void) writeable;
    (void) executable;
    // if (as->as_vbase1 == 0) {
    // 	as->as_vbase1 = vaddr;
    // 	as->as_npages1 = npages;
    // 	return 0;
    // }

    // if (as->as_vbase2 == 0) {
    // 	as->as_vbase2 = vaddr;
    // 	as->as_npages2 = npages;
    // 	return 0;
    // }

    if (as->text.region_end == 0 && as->text.region_start == 0) {
        as->text.region_start = vaddr;
        as->text.npages = npages;
        as->text.region_end = vaddr + npages*PAGE_SIZE;
        as->text.offset_attribute = offset;
        as->text.file_size_attribute = file_size;
        //kprintf("END TEXT IS %p\n", as->text.region_end);

        return 0;
    }

    if (as->data.region_end == 0 && as->data.region_start == 0) {
        as->data.region_start = vaddr;
        as->data.npages = npages;
        as->data.region_end = vaddr + npages*PAGE_SIZE;
        as->data.offset_attribute = offset;
        as->data.file_size_attribute = file_size;

        // Now assign heap.
        as->heap.region_start = as->data.region_end;
        as->heap.region_end = as->heap.region_start;
        as->heap.npages = 0;
        as->heap.offset_attribute = offset;
        as->heap.file_size_attribute = file_size;
        //                kprintf("HELLO HEAP IS RUN\n");
        //as->max_heap = as->heap.region_start + DEFAULT_SBRK_LIMIT; in header file

        return 0;
    }

    /*
     * Support for more than two regions is not available.
     */
    kprintf("dumbvm: Warning: too many regions\n");
    return EUNIMP;
}

int
as_prepare_load(struct addrspace *as)//donezo
{
    // assert(as->as_pbase1 == 0);
    // assert(as->as_pbase2 == 0);
    // assert(as->as_stackpbase == 0);

    // as->as_pbase1 = getppages(as->as_npages1);
    // if (as->as_pbase1 == 0) {
    // 	return ENOMEM;
    // }

    // as->as_pbase2 = getppages(as->as_npages2);
    // if (as->as_pbase2 == 0) {
    // 	return ENOMEM;
    // }

    // as->as_stackpbase = getppages(DUMBVM_STACKPAGES);
    // if (as->as_stackpbase == 0) {
    // 	return ENOMEM;
    // }

    //(void)as;

    // assert(as->stack.region_start == 0);
    // assert(as->heap.region_start == 0);
    // assert(as->text.region_start == 0);
    // assert(as->data.region_start == 0);


    // 	unsigned int i;
    //	paddr_t heap_base_paddr;
    //	for (i = 0; i < as->heap.npages; i++) {
    //		heap_base_paddr = getppages(1);
    //		add_pte(as, heap_base_paddr, as->heap.region_start + i*PAGE_SIZE);
    //
    //		// vaddr_t heap_vaddr = old->heap.region_start + i*PAGE_SIZE;
    //		// paddr_t heap_paddr = find_paddr(old, heap_vaddr);
    //	}
    //
    //	paddr_t text_base_paddr;
    //	for (i = 0; i < as->text.npages; i++) {
    //		text_base_paddr = getppages(1);
    //		add_pte(as, text_base_paddr, as->text.region_start + i*PAGE_SIZE);
    //
    //		// vaddr_t text_vaddr = old->text.region_start + i*PAGE_SIZE;
    //		// paddr_t text_paddr = find_paddr(old, text_vaddr);
    //	}
    //
    //	paddr_t data_base_paddr;
    //	for (i = 0; i < as->data.npages; i++) {
    //		data_base_paddr = getppages(1);
    //		add_pte(as, data_base_paddr, as->data.region_start + i*PAGE_SIZE);
    //
    //		// vaddr_t data_vaddr = old->data.region_start + i*PAGE_SIZE;
    //		// paddr_t data_paddr = find_paddr(old, data_vaddr);
    //	}
    (void) as;
    return 0;
}

int
as_complete_load(struct addrspace *as) {
    (void) as;
    return 0;
}

/*  we just define the stack as USERSTACK and let runprogram change it later on  */
int
as_define_stack(struct addrspace *as, vaddr_t *stackptr)//donezo
{
    assert(as->stack.region_end == 0);

    as->stack.region_start = USERSTACK - 8192 * PAGE_SIZE;//6000 works
    as->stack.region_end = USERSTACK;

    // 	unsigned int i;
    // 	paddr_t stack_base_paddr;
    //	for (i = 1; i <= 24; i++) {
    //		stack_base_paddr = getppages(1);
    //		add_pte(as, stack_base_paddr, as->stack.region_end - i*PAGE_SIZE);
    //
    //		// vaddr_t stack_vaddr = old->stack.region_start + i*PAGE_SIZE;
    //		// paddr_t stack_paddr = find_paddr(old, stack_vaddr);
    //	}

    *stackptr = USERSTACK;
    return 0;
}

/*  deep copy of the arg address space  */
int
as_copy(struct addrspace *old, struct addrspace **ret) {
    struct addrspace *new;

    new = as_create(old->program_name);
    if (new == NULL) {
        return ENOMEM;
    }

    // new->as_vbase1 = old->as_vbase1;
    // new->as_npages1 = old->as_npages1;
    // new->as_vbase2 = old->as_vbase2;
    // new->as_npages2 = old->as_npages2;

    // if (as_prepare_load(new)) {
    // 	as_destroy(new);
    // 	return ENOMEM;
    // }

    // assert(new->as_pbase1 != 0);
    // assert(new->as_pbase2 != 0);
    // assert(new->as_stackpbase != 0);

    // memmove((void *)PADDR_TO_KVADDR(new->as_pbase1),
    // 	(const void *)PADDR_TO_KVADDR(old->as_pbase1),
    // 	old->as_npages1*PAGE_SIZE);

    // memmove((void *)PADDR_TO_KVADDR(new->as_pbase2),
    // 	(const void *)PADDR_TO_KVADDR(old->as_pbase2),
    // 	old->as_npages2*PAGE_SIZE);

    // memmove((void *)PADDR_TO_KVADDR(new->as_stackpbase),
    // 	(const void *)PADDR_TO_KVADDR(old->as_stackpbase),
    // 	DUMBVM_STACKPAGES*PAGE_SIZE);


    //step 1 of Ivan's cookbook
    //all of stack region contents
    new->head_of_page_table = NULL;
//    new->program_name = old->program_name;//already did the name earlier
    new->stack.region_start = old->stack.region_start;
    new->stack.region_end = old->stack.region_end;
    new->stack.npages = old->stack.npages;
    new->stack.offset_attribute = old->stack.offset_attribute;
    new->stack.file_size_attribute = old->stack.file_size_attribute;
    new->heap.region_start = old->heap.region_start;
    new->heap.region_end = old->heap.region_end;
    new->heap.npages = old->heap.npages;
    new->heap.offset_attribute = old->heap.offset_attribute;
    new->heap.file_size_attribute = old->heap.file_size_attribute;
    new->text.region_start = old->text.region_start;
    new->text.region_end = old->text.region_end;
    new->text.npages = old->text.npages;
    new->text.offset_attribute = old->text.offset_attribute;
    new->text.file_size_attribute = old->text.file_size_attribute;
    new->data.region_start = old->data.region_start;
    new->data.region_end = old->data.region_end;
    new->data.npages = old->data.npages;
    new->data.offset_attribute = old->data.offset_attribute;
    new->data.file_size_attribute = old->data.file_size_attribute;

    //make sure the old address space hasn't just been newly initialized
    assert(new->stack.region_start != 0);
    assert(new->heap.region_start != 0);
    assert(new->text.region_start != 0);
    assert(new->data.region_start != 0);

    //step 2: allocated physical address through getppages

    if (old->head_of_page_table == NULL) { //if its the first one
        //		as->head_of_page_table = new_entry;
        return;
    }
    int spl;
    spl = splhigh();
    
    struct page_table_entry* current = old->head_of_page_table; //if head not empty
    paddr_t copied_content_paddr;
    while (current != NULL) {
        copied_content_paddr = getppages(1);

        add_pte(new, copied_content_paddr, current->page_table_entry_vaddr); //the copy has the same virtual address as before
        paddr_t prev_content_paddr = current->page_table_entry_paddr;
//        paddr_t prev_content_paddr = find_paddr(old, current->page_table_entry_vaddr);
        memmove((void *)PADDR_TO_KVADDR(copied_content_paddr), (const void *)PADDR_TO_KVADDR(prev_content_paddr), PAGE_SIZE);//page size might be 1 not 4096 check
        //            
        //            
        //		if (cur->page_table_entry_vaddr == target_vaddr) {
        //			found = 1;
        //			target_paddr = cur->page_table_entry_paddr;
        //			break;
        //		}
        
        current = current->next_page_table_entry;
    }

    splx(spl);


    //	unsigned int i;
    //	paddr_t stack_base_paddr;			//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! check if its + or - for stack
    //	for (i = 0; i < new->stack.npages; i++) {			//as copy for each stack page
    //		stack_base_paddr = getppages(1);
    //		add_pte(new, stack_base_paddr, new->stack.region_start - i*PAGE_SIZE);	
    //
    //		//find old's physical address
    //		vaddr_t stack_vaddr = old->stack.region_start - i*PAGE_SIZE;			//stack moves downward
    //		paddr_t stack_paddr = find_paddr(old, stack_vaddr);
    //
    //		//use the new's physical and old's virtual then translate
    //		memmove((void *)PADDR_TO_KVADDR(stack_base_paddr), (const void *)PADDR_TO_KVADDR(stack_paddr), 1);
    //	}
    //
    //	paddr_t heap_base_paddr;//check this
    //	for (i = 0; i < new->heap.npages; i++) {
    //		heap_base_paddr = getppages(1);
    //		add_pte(new, heap_base_paddr, new->heap.region_start + i*PAGE_SIZE);
    //
    //		vaddr_t heap_vaddr = old->heap.region_start + i*PAGE_SIZE;
    //		paddr_t heap_paddr = find_paddr(old, heap_vaddr);
    //
    //		memmove((void *)PADDR_TO_KVADDR(heap_base_paddr), (const void *)PADDR_TO_KVADDR(heap_paddr), 1);
    //	}
    //
    ////	paddr_t text_base_paddr;
    ////	for (i = 0; i < new->text.npages; i++) {
    ////		text_base_paddr = getppages(1);
    ////		add_pte(new, text_base_paddr, new->text.region_start + i*PAGE_SIZE);
    ////
    ////		vaddr_t text_vaddr = old->text.region_start + i*PAGE_SIZE;
    ////		paddr_t text_paddr = find_paddr(old, text_vaddr);
    ////
    ////		memmove((void *)PADDR_TO_KVADDR(text_base_paddr), (const void *)PADDR_TO_KVADDR(text_paddr), 1);
    ////	}
    //	
    //	paddr_t data_base_paddr;
    //	for (i = 0; i < new->data.npages; i++) {
    //		data_base_paddr = getppages(1);
    //		add_pte(new, data_base_paddr, new->data.region_start + i*PAGE_SIZE);
    //
    //		vaddr_t data_vaddr = old->data.region_start + i*PAGE_SIZE;
    //		paddr_t data_paddr = find_paddr(old, data_vaddr);
    //
    //		memmove((void *)PADDR_TO_KVADDR(data_base_paddr), (const void *)PADDR_TO_KVADDR(data_paddr), 1);
    //	}


    //from Ivan:
    //the new address should have the same virtual address, stack heap, and all the virtual addresses
    //new one should not have a physical address
    //vm_fault returns physical address when a process asks for it through giving it the virtual address
    //
    //access your coremap,
    //add in proper pagetable entries 

    //copy vaddr DONE
    //allocate physcial addrs through coremap
    //map virtual to physical for the stack and the heap for the new process
    //memmove the data from old satck and heal to new's stack and heap
    //no need to do this for text 

    *ret = new;
    return 0;
}

/*  add a new pte to the as' page table linked list --- do access permission and valid bit later  */
void add_pte(struct addrspace* as, paddr_t paddr, vaddr_t vaddr) {
    vaddr &= PAGE_FRAME;
    struct page_table_entry* new_entry = kmalloc(sizeof (struct page_table_entry));
    new_entry->page_table_entry_paddr = paddr;
    new_entry->page_table_entry_vaddr = vaddr;
    new_entry->next_page_table_entry = NULL;

    if (as->head_of_page_table == NULL) { //if its the first one
        as->head_of_page_table = new_entry;
        return;
    }

    struct page_table_entry* current_entry = as->head_of_page_table;

    while (current_entry->next_page_table_entry != NULL) { //there are more ptes so loop
        current_entry = current_entry->next_page_table_entry;
    }

    current_entry->next_page_table_entry = new_entry;
}

/*  find the old stack virtual address and get the corresponding physical address  */
paddr_t find_paddr(struct addrspace* as, vaddr_t target_vaddr) {
    paddr_t target_paddr;
    struct page_table_entry* cur = as->head_of_page_table;
    int found = 0;

    while (cur != NULL) {
        if (cur->page_table_entry_vaddr == target_vaddr) {
            found = 1;
            target_paddr = cur->page_table_entry_paddr;
            break;
        }

        cur = cur->next_page_table_entry;
    }

    if (found)
        return target_paddr;
    else
        return 0;
}
