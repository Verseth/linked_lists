#include "linked_lists.h"

VALUE rb_mLinkedLists;

void
Init_linked_lists(void)
{
  rb_mLinkedLists = rb_define_module("LinkedLists");
}
