#ifndef TEXT_MESSAGE_H
#define TEXT_MESSAGE_H

struct text_message {
	char   cmd[16];
	void * ud;
};

struct text_message *
text_message_alloc();

void
text_message_free(struct text_message *self);

const char *
text_message_unpack(struct text_message *self, void **ud);

struct text_message *
text_message_pack(struct text_message *self, const char *cmd, void *ud);

#endif