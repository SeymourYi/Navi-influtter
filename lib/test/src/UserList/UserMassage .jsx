import React, { useEffect, useState } from 'react';
import axios from 'axios';  // Import axios for making HTTP requests
import './UserMassage.css'; // Import CSS for styling

const UserMassage = () => {
  // const token = useToken();
  // const handusrinfo = handleuserinfo();
  // const [users, setUsers] = useState([]);

  // console.log('====================================');
  // console.log(handusrinfo, token);
  // console.log('====================================');

  // // API setup using the token and username from context
  // const API_getArticles = `/user/myfriend?username=${handusrinfo.user_info.username}`;

  // Function to fetch the users data using axios
  // const getMassage = async () => {
  //   try {
  //     const response = await axios.get(API_getArticles, {
  //       headers: {
  //         Authorization: token,
  //       }
  //     });
  //     console.log(response.data); // Log the response data
  //     setUsers(response.data); // Update the state with the response data
  //   } catch (error) {
  //     console.error('Error fetching user data:', error); // Log any errors
  //   }
  // };

  useEffect(() => {
    // getMassage();  // Fetch user data when the component is mounted
  }, []);

  return (
    <div className="scroll-container">
      123
      {/* {users.map((user) => (
        <div key={user.id} className="main" onClick={() => alert(`Go to profile of ${user.username}`)}>
          <div className="userpic">
            <img className="userpic-content" src={user.userPic} alt={`${user.username}'s profile`} />
          </div>
          <div className="userinfo">
            <div className="username">
              <span className="username-content">{user.nickname}</span>
              <span className="username-id">@{user.username}</span>
            </div>
            <div className="userbio">
              <p className="userbio-content">{user.bio}</p>
            </div>
          </div>
        </div>
      ))} */}
    </div>
  );
};

export default UserMassage;
