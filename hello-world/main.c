#include "linux/printk.h"
#include <linux/init.h>
#include <linux/module.h>

static int __init my_init(void) {
  printk("Hello world!\n");
  return 0;
}

static void __exit my_exit(void) { printk("Goodbye!\n"); }

module_init(my_init);
module_exit(my_exit);

MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("Hello world");
MODULE_AUTHOR("Morten");
