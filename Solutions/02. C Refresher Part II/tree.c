// tree.c -- use structs and pointers to build a tree of nodes

/* compile with
gcc -g -o tree tree.c
(Linux)
cc -g -o tree tree.c
(Mac OS X)
*/

#include <stdio.h>	// for printf
#include <stdlib.h>	// for malloc

typedef struct TreeNode {
    int value;
    struct TreeNode *left;
    struct TreeNode *right;
} TreeNode;


void addValue (TreeNode *node, int value)
{
    if (value < node->value) {
	// left side
	if (node->left == NULL) {
	    TreeNode *newNode = malloc (sizeof(TreeNode));
	    newNode->value = value;
	    newNode->left = newNode->right = NULL;
	    node->left = newNode;
	} else {
	    addValue (node->left, value);
	}
    } else {
	// right side
	if (node->right == NULL) {
	    TreeNode *newNode = malloc (sizeof(TreeNode));
	    newNode->value = value;
	    newNode->left = newNode->right = NULL;
	    node->right = newNode;
	} else {
	    addValue (node->right, value);
	}
    }

} // addValue

#define TRUE 1
#define FALSE 0

int findValue (TreeNode *node, int value)
{
    if (node == NULL) {
	return (FALSE);

    } else if (node->value == value) {
	return (TRUE);

    } else {
	if (value < node->value) {
	    return (findValue(node->left, value));
	} else {
	    return (findValue(node->right, value));
	}
    }

} // findValue


int main (int argc, char *argv[])
{
    TreeNode root;

    // put 23 in manually to bootstrap the tree
    root.value = 23;
    root.left = root.right = NULL;

    // now add some stuff

    addValue (&root, 5);
    addValue (&root, 50);
    addValue (&root, 8);
    addValue (&root, 2);
    addValue (&root, 34);

    if (findValue(&root, 23)) {
	printf ("23 lives in the tree\n");
    } else {
	printf ("23 doesn't live in the tree\n");
    }

    if (findValue(&root, 42)) {
	printf ("42 lives in the tree\n");
    } else {
	printf ("42 doesn't live in the tree\n");
    }

} // main
