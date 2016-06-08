var CommentBox = React.createClass({
	render: function () {
		// body...
		return React.COM.div({ className:"commentBox"}, "Hello world! i am a commentBox")
	}
});

CommentBox = React.createFactory(CommentBox);

ReactDOM.render(
	CommentBox(null),
	document.getElementById("content")
);