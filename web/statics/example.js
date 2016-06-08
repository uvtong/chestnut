var Timer = React.createClass({
	getInitialState: function () {
		// body...
		return {secondsElapsed: 0};
	},
	tick: function () {
		// body...
		this.setState({secondsElapsed: this.state.secondsElapsed + 1})
	},
	componentDidMount: function () {
		// body...
		this.interval = setInterval(this.tick, 1000)
	},
	componentWillUnmount: function () {
		// body...
		clearInterval(this.interval)
	},
	render: function () {
		// body...
		return (<div>Seconds Elapsed: {this.state.secondsElapsed}</div>);
	}
});

var Comment = React.createClass({
	render: function () {
		// body...
		return (
			<div className="comment">
				<h2 className="commentAuthor">
					{this.props.author}
				</h2>
				{this.props.children}
			</div>
		);
	},
});

var CommentList = React.createClass({
	render: function () {
		// body...
		var commentNodes = this.props.data.map(function (comment) {
			// body...
			return (
				<Comment author={comment.author} key={comment.id}>
					{comment.text}
				</Comment>
			);
		});
		return (
			<div className="commentList">
				{commentNodes}
			</div>
		);
	},
});

var CommentForm = React.createClass({
	render: function () {
		// body...
		return (
			<div className="commentForm">
				Hello
			<div>
		);
	},
});

var CommentBox = React.createClass({
	loadCommentsFromServer: function () {
		// $.ajax({
		// 	url:"/test",
  //           type:"POST",
  //           dataType:"json",
  //           success:function(data) {
  //           	this.setState({data:data});
  //           }.bind(this),
  //           error:function() {
  //               console.error(this.props.url, status, err.toString());
  //           }.bind(this),
  //      	});
	},
	getInitialState: function () {
		// body...
		return {data:[]}
	},
	componentDidMount: function () {
		// body...
		console.log(this.state.data.length)
		this.loadCommentsFromServer();
		setInterval(this.loadCommentsFromServer, this.props.pollInterval);
	},
	render: function () {
		// body...
		return (
			<div className="commentBox">
				<h1>Comments</h1>
				<CommentList data={this.state.data} />
				<CommentForm />
			</div>
		);
	}
});

ReactDOM.render(
	<CommentBox url="/test" pollInterval={2000}/>,
	document.getElementById("content")
);