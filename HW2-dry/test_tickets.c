#include <stdio.h>
#include <stdlib.h>
#include <stddef.h> // for NULL

// Definition of the ListNode structure
struct ListNode {
    int val;                 // The value of the node
    struct ListNode* next;   // Pointer to the next node
} __attribute__((packed));   // Prevents padding in the structure

// Function to reverse and update the list as described
struct ListNode* sod(struct ListNode* head, int len) {
    if (head == NULL) { // Base case: If the head is NULL, return NULL
        return NULL;
    }

    struct ListNode* newHead = head; // Initialize newHead with the current node

    if (head->next != NULL) { // If there is a next node, recursively process it
        newHead = sod(head->next, len - 1); // Recursive call for the next node
        head->next->next = head; // Reverse the link
    }

    head->next = NULL; // Disconnect the current node from its original next

    head->val += len; // Update the value of the current node

    return newHead; // Return the new head of the reversed list
}

// Helper function to create a new node
struct ListNode* createNode(int val) {
    struct ListNode* node = (struct ListNode*)malloc(sizeof(struct ListNode));
    node->val = val;
    node->next = NULL;
    return node;
}

// Helper function to print the linked list
void printList(struct ListNode* head) {
    struct ListNode* current = head;
    while (current != NULL) {
        printf("%d -> ", current->val);
        current = current->next;
    }
    printf("NULL\n");
}

// Main function
int main() {
    // Create the linked list: 2 -> 3 -> 4 -> 12 -> 5 -> 5 -> 9 -> NULL
    struct ListNode* head = createNode(2);
    head->next = createNode(3);
    head->next->next = createNode(4);
    head->next->next->next = createNode(12);
    head->next->next->next->next = createNode(5);
    head->next->next->next->next->next = createNode(5);
    head->next->next->next->next->next->next = createNode(9);

    printf("Original list:\n");
    printList(head);

    // Call the sod function
    int len = 7; // Length of the original list
    head = sod(head, len);

    printf("Transformed list:\n");
    printList(head);

    // Free the allocated memory
    struct ListNode* current = head;
    while (current != NULL) {
        struct ListNode* temp = current;
        current = current->next;
        free(temp);
    }

    return 0;
}

/**
gcc -o test_tickets test_tickets.c
./test_tickets
 */