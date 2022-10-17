#include "linked_lists.h"

typedef struct linkedListNode {
  struct linkedListNode *next;
  VALUE value;
} linkedListNodeType;
typedef linkedListNodeType *linkedListNodePtr;

typedef struct linkedList {
  linkedListNodeType *head;
} linkedListType;
typedef linkedListType *linkedListPtr;

static void linked_list_mark(void *ptr) {
  linkedListPtr linked_list = ptr;
  // iterate over every ruby object and mark it
  linkedListNodePtr node = linked_list->head;

  while(node != NULL) {
    if(node->value) rb_gc_mark(node->value);
    node = node->next;
  }
}

static void linked_list_free(void *ptr) {
  free(ptr);
}

static size_t linked_list_memsize(const void *ptr)
{
  return sizeof(linkedListType);
}

const rb_data_type_t linked_list_data_type = {
  .wrap_struct_name = "linkedList",
  .function = {
    .dmark = linked_list_mark,
    .dfree = linked_list_free,
    .dsize = linked_list_memsize
  },
  .flags = RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE rb_linked_list_allocate(VALUE klass) {
  linkedListPtr linked_list = malloc(sizeof(linkedListType));
  VALUE obj = TypedData_Wrap_Struct(klass, &linked_list_data_type, linked_list);

  linked_list->head = NULL;

  return obj;
}

linkedListNodePtr new_c_node() {
  linkedListNodePtr node = malloc(sizeof(linkedListNodeType));
  node->next = NULL;
  return node;
}

linkedListNodePtr new_c_node_value(VALUE value) {
  linkedListNodePtr node = new_c_node();
  node->value = value;
  return node;
}

VALUE rb_linked_list_append(VALUE self, VALUE value) {
  linkedListPtr linked_list;
  TypedData_Get_Struct(self, linkedListType, &linked_list_data_type, linked_list);
  linkedListNodePtr node = linked_list->head;
  // rb_funcall(rb_cObject, rb_intern("puts"), 1, rb_str_new_cstr("Pushuje"));
  if(node == NULL) {
    linked_list->head = new_c_node_value(value);
    return self;
  }

  while(node->next != NULL) { node = node->next; }
  node->next = new_c_node_value(value);

  return self;
}

VALUE rb_linked_list_prepend(VALUE self, VALUE value) {
  linkedListPtr linked_list;
  TypedData_Get_Struct(self, linkedListType, &linked_list_data_type, linked_list);

  linkedListNodePtr new_node = new_c_node_value(value);
  new_node->next = linked_list->head;
  linked_list->head = new_node;

  return self;
}

VALUE rb_linked_list_shift(VALUE self) {
  linkedListPtr linked_list;
  TypedData_Get_Struct(self, linkedListType, &linked_list_data_type, linked_list);
  if(!linked_list->head) return Qnil;

  linkedListNodePtr new_head = linked_list->head->next;
  VALUE removed_value = linked_list->head->value;
  free(linked_list->head);
  linked_list->head = new_head;

  return removed_value;
}

VALUE rb_linked_list_inspect(VALUE self) {
  linkedListPtr linked_list;
  TypedData_Get_Struct(self, linkedListType, &linked_list_data_type, linked_list);
  linkedListNodePtr node = linked_list->head;

  VALUE s, str = rb_str_buf_new2("#<");
  rb_str_buf_append(str, rb_class_name(rb_class_of(self)));
  rb_str_buf_cat2(str, " {");
  long i = 0;
  while(node != NULL) {
    s = rb_inspect(node->value);
    if (i > 0) rb_str_buf_cat2(str, ", ");
    rb_str_buf_append(str, s);
    node = node->next;
    i++;
  }
  rb_str_buf_cat2(str, "}>");
  return str;
}

VALUE rb_mLinkedLists;
VALUE rb_cLinkedList;

void
Init_linked_lists(void)
{
  rb_mLinkedLists = rb_define_module("LinkedLists");
  rb_cLinkedList = rb_define_class("LinkedList", rb_cObject);
  rb_define_alloc_func(rb_cLinkedList, rb_linked_list_allocate);

  rb_define_method(rb_cLinkedList, "append", rb_linked_list_append, 1);
  rb_define_alias(rb_cLinkedList, "<<", "append");
  rb_define_method(rb_cLinkedList, "prepend", rb_linked_list_prepend, 1);
  rb_define_alias(rb_cLinkedList, ">>", "prepend");
  rb_define_method(rb_cLinkedList, "shift", rb_linked_list_shift, 0);
  rb_define_method(rb_cLinkedList, "inspect", rb_linked_list_inspect, 0);
}
